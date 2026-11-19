/**
 * API simulada para el laboratorio de seguridad de APIs.
 *  - OAuth 2.0 (grants client_credentials y password) que emite JWT
 *  - Verificacion JWT estricta: lista blanca de algoritmos, iss, aud, exp, scope
 *  - Validacion de entradas con lista blanca (express-validator)
 *  - Rate limiting: 100 solicitudes / minuto por IP en /api/*
 *
 * Uso: npm install && npm start   ->   http://localhost:3000
 * SOLO PARA LABORATORIO: credenciales y secreto de prueba.
 */
const crypto = require('crypto');
const express = require('express');
const jwt = require('jsonwebtoken');
const rateLimit = require('express-rate-limit');
const { query, body, validationResult } = require('express-validator');

const PORT = process.env.PORT || 3000;
// Secreto de >= 256 bits. En produccion: variable de entorno / gestor de secretos.
const JWT_SECRET = process.env.JWT_SECRET || crypto.randomBytes(32).toString('hex');
const JWT_ISSUER = 'https://auth.lab.local';
const JWT_AUDIENCE = 'api-security-lab';
const TOKEN_TTL_SECONDS = 15 * 60;

// Clientes OAuth y usuarios de prueba (no reutilizar fuera del laboratorio)
const CLIENTS = {
  'lab-client': { secret: 'lab-secret-2026', scopes: ['products:read', 'products:write'] },
  'readonly-client': { secret: 'readonly-secret-2026', scopes: ['products:read'] },
};
const USERS = {
  analyst: { password: 'Analyst#2026', scopes: ['products:read'] },
};

// "Base de datos" en memoria; el acceso es por clave, nunca concatenando cadenas
const products = new Map([
  [1, { id: 1, name: 'Firewall Appliance', price: 1200.0 }],
  [2, { id: 2, name: 'IDS Sensor', price: 850.5 }],
  [3, { id: 3, name: 'VPN Gateway', price: 640.0 }],
]);
let nextId = 4;

const app = express();
app.disable('x-powered-by');
app.use(express.json({ limit: '10kb' }));
app.use(express.urlencoded({ extended: false, limit: '10kb' }));
app.use((req, res, next) => {
  res.set('X-Content-Type-Options', 'nosniff');
  res.set('X-Frame-Options', 'DENY');
  res.set('Cache-Control', 'no-store');
  next();
});

// ---------------- OAuth 2.0 token endpoint (RFC 6749) ----------------
app.post('/oauth/token', (req, res) => {
  const { grant_type, client_id, client_secret, username, password, scope } = req.body;
  const client = CLIENTS[client_id];
  if (!client || !safeEqual(client.secret, client_secret || '')) {
    return res.status(401).json({ error: 'invalid_client' });
  }

  let subject;
  let allowed;
  if (grant_type === 'client_credentials') {
    subject = client_id;
    allowed = client.scopes;
  } else if (grant_type === 'password') {
    const user = USERS[username];
    if (!user || !safeEqual(user.password, password || '')) {
      return res.status(400).json({ error: 'invalid_grant' });
    }
    subject = username;
    allowed = user.scopes.filter((s) => client.scopes.includes(s));
  } else {
    return res.status(400).json({ error: 'unsupported_grant_type' });
  }

  const requested = scope ? String(scope).split(' ') : allowed;
  const granted = requested.filter((s) => allowed.includes(s));
  if (granted.length === 0) return res.status(400).json({ error: 'invalid_scope' });

  const token = jwt.sign({ scope: granted.join(' '), client_id }, JWT_SECRET, {
    algorithm: 'HS256',
    expiresIn: TOKEN_TTL_SECONDS,
    issuer: JWT_ISSUER,
    audience: JWT_AUDIENCE,
    subject,
  });
  res.json({ access_token: token, token_type: 'Bearer', expires_in: TOKEN_TTL_SECONDS, scope: granted.join(' ') });
});

// ---------------- Middleware de seguridad para /api ----------------
const apiLimiter = rateLimit({
  windowMs: 60 * 1000,
  limit: 100,
  standardHeaders: 'draft-7',
  legacyHeaders: false,
  message: { error: 'too_many_requests', detail: 'Limite de 100 solicitudes por minuto' },
});

function authenticate(req, res, next) {
  const header = req.get('Authorization') || '';
  const [type, token] = header.split(' ');
  if (type !== 'Bearer' || !token) {
    res.set('WWW-Authenticate', 'Bearer realm="api"');
    return res.status(401).json({ error: 'invalid_request', detail: 'Falta token Bearer' });
  }
  try {
    // Lista blanca: rechaza alg "none", RS/HS confusion y cualquier otro algoritmo
    req.auth = jwt.verify(token, JWT_SECRET, {
      algorithms: ['HS256'],
      issuer: JWT_ISSUER,
      audience: JWT_AUDIENCE,
      clockTolerance: 5,
    });
    return next();
  } catch (err) {
    res.set('WWW-Authenticate', 'Bearer error="invalid_token"');
    return res.status(401).json({ error: 'invalid_token', detail: err.message });
  }
}

const requireScope = (needed) => (req, res, next) => {
  const scopes = (req.auth.scope || '').split(' ');
  if (!scopes.includes(needed)) {
    return res.status(403).json({ error: 'insufficient_scope', required: needed });
  }
  next();
};

function rejectInvalid(req, res, next) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ error: 'validation_error', details: errors.array().map(({ path, msg }) => ({ field: path, msg })) });
  }
  next();
}

app.use('/api', apiLimiter, authenticate);

// ---------------- Endpoints protegidos ----------------
app.get(
  '/api/products',
  requireScope('products:read'),
  query('id').optional().isInt({ min: 1, max: 99999 }).withMessage('id debe ser entero entre 1 y 99999').toInt(),
  rejectInvalid,
  (req, res) => {
    if (req.query.id === undefined) return res.json([...products.values()]);
    const item = products.get(req.query.id);
    return item ? res.json(item) : res.status(404).json({ error: 'not_found' });
  }
);

app.post(
  '/api/products',
  requireScope('products:write'),
  body('name').isString().trim().matches(/^[A-Za-z0-9 ._-]{3,50}$/).withMessage('name: 3-50 caracteres alfanumericos'),
  body('price').isFloat({ min: 0, max: 1000000 }).withMessage('price debe ser decimal entre 0 y 1000000').toFloat(),
  rejectInvalid,
  (req, res) => {
    const item = { id: nextId++, name: req.body.name, price: req.body.price };
    products.set(item.id, item);
    res.status(201).json(item);
  }
);

app.get('/health', (req, res) => res.json({ status: 'ok' }));
app.use((req, res) => res.status(404).json({ error: 'not_found' }));
app.use((err, req, res, next) => {
  if (err.type === 'entity.parse.failed') return res.status(400).json({ error: 'malformed_json' });
  if (err.type === 'entity.too.large') return res.status(413).json({ error: 'payload_too_large' });
  console.error(err);
  res.status(500).json({ error: 'server_error' });
});

function safeEqual(a, b) {
  const x = Buffer.from(String(a));
  const y = Buffer.from(String(b));
  return x.length === y.length && crypto.timingSafeEqual(x, y);
}

app.listen(PORT, () => console.log(`API de laboratorio escuchando en http://localhost:${PORT}`));
