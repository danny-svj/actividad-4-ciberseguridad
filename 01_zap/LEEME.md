# Reporte de OWASP ZAP

Guarda aquí el reporte HTML exportado desde ZAP (*Report > Generate Report*), por ejemplo `ZAP-Report-DVWA.html`.

Pasos del escaneo:

1. DVWA Security en **Low** e iniciar sesión desde el navegador que abre ZAP.
2. Crear un Context "DVWA" (`http://<ip-dvwa>/.*`), excluir `logout.php` y `setup.php`.
3. Spider + AJAX Spider.
4. Active Scan con la política por defecto.
5. Exportar el reporte a esta carpeta.
