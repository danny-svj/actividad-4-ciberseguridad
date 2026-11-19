# Capturas pendientes

Toma estas capturas **en tu propio laboratorio** y guárdalas aquí con el nombre exacto. El README ya las enlaza, así que aparecen solas al subirlas.

| Archivo | Qué debe verse |
| --- | --- |
| `01-entorno-dvwa-security-low.png` | DVWA Security en nivel **Low** |
| `02-zap-arbol-sitios.png` | Árbol de sitios de ZAP después del Spider |
| `03-sqli-or-1-1.png` | `1' OR '1'='1` mostrando todos los usuarios |
| `04-sqli-union-select.png` | `UNION SELECT user,password` mostrando hashes |
| `05-sqli-zap-alerta.png` | Alerta SQL Injection en ZAP (Attack/Evidence) |
| `06-xss-alert-popup.png` | Ventana `alert` del payload XSS |
| `07-xss-zap-alerta.png` | Alerta Cross Site Scripting en ZAP |
| `08-acceso-roto.png` | Request modificada (cookie `security`) con respuesta 200 |
| `09-zap-alertas-total.png` | Panel de alertas o reporte de ZAP |
| `10-api-npm-start.png` | API corriendo (`npm start`) |
| `11-oauth-token.png` | Postman 1.1: token obtenido (200) |
| `12-jwt-sin-token.png` | Postman 2.1: 401 sin token |
| `13-jwt-alg-none.png` | Postman 2.3: 401 con token `alg:none` |
| `14-validacion-sqli.png` | Postman 3.1: 400 al enviar SQLi |
| `15-rate-limiting-429.png` | Collection Runner: 101–105 en 429 |
| `16-packet-tracer-topologia.png` | Topología en Packet Tracer |
| `17-packet-tracer-vpn.png` | `show crypto ipsec sa` con encaps/decaps > 0 |
| `18-pfsense-reglas.png` | Firewall > Rules en pfSense |
| `19-pfsense-dnsbl.png` | pfBlockerNG bloqueando un dominio de phishing |
| `20-snort-reglas.png` | custom.rules cargadas en Snort |
| `21-nmap-escaneo.png` | Salida de `nmap -sS` desde Kali |
| `22-snort-alertas.png` | Services > Snort > Alerts con los SID 1000001+ |
| `23-snort-bloqueado.png` | Snort > Blocked con la IP de Kali |

Reporte de ZAP: *Report > Generate Report* (HTML) y guárdalo en [`../01_zap/`](../01_zap/).
