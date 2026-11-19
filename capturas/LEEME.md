# Capturas

## ✅ Ya incluidas (ejecución real en DVWA y la API local)

| Archivo | Qué muestra |
| --- | --- |
| `01-entorno-dvwa-security-low.png` | DVWA en nivel Low |
| `02-file-inclusion-etc-passwd.png` | File Inclusion expone `/etc/passwd` |
| `03-sqli-or-1-1.png` | `1' OR '1'='1` devuelve todos los usuarios |
| `04-sqli-union-select.png` | `UNION SELECT` extrae usuarios y hashes |
| `05-sqli-zap-alerta.png` | Alerta High de SQL Injection en ZAP |
| `06-xss-ejecutado.png` | JavaScript inyectado se ejecuta y lee la cookie |
| `07-xss-zap-alerta.png` | Alerta High de XSS reflejado en ZAP |
| `08-acceso-roto.png` | Usuario `gordonb` (sin rol admin) entra a la página de administración |
| `09-zap-resumen.png` | Resumen del reporte de ZAP (28 alertas) |
| `10-api-npm-start.png` | API corriendo |
| `11-oauth-token.png` | Pruebas OAuth 2.0 |
| `12-jwt-pruebas.png` | Sin token, `alg:none`, firma alterada y scope → rechazados |
| `13-zap-path-traversal.png` | Alerta High de Path Traversal en ZAP |
| `13b-zap-rfi.png` | Alerta High de Remote File Inclusion en ZAP |
| `14-validacion-entradas.png` | SQLi y XSS bloqueados con 400 |
| `15-rate-limiting-429.png` | Solicitudes 101–105 → 429 |
| `16-laboratorio-docker.png` | Contenedores: DVWA, Snort y atacantes |
| `20-snort-reglas.png` | Reglas personalizadas cargadas en Snort |
| `21-nmap-escaneo.png` | nmap antes del bloqueo (puerto 80 abierto) |
| `22-snort-alertas.png` | Alertas de las 7 reglas de escaneo |
| `23-snort-bloqueo.png` | IP atacante bloqueada; segundo escaneo filtrado |
| `24-snort-ataques-web.png` | SQLi y XSS detectados por Snort |

## ⏳ Pendientes (necesitan pfSense, que no corre en Mac con chip M2)

| Archivo | Qué debe verse |
| --- | --- |
| `17-pfsense-vpn-ipsec.png` | VPN > IPsec > Status con el túnel |
| `18-pfsense-reglas.png` | Firewall > Rules |
| `19-pfsense-dnsbl.png` | pfBlockerNG bloqueando un dominio de phishing |
