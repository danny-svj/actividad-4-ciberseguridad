#!/bin/bash
# Matriz de pruebas de segmentacion. Salida: texto para capturas
t() { # contenedor destino puerto esperado descripcion
  if docker exec "$1" nc -z -w 2 "$2" "$3" >/dev/null 2>&1; then r="PERMITIDO"; else r="BLOQUEADO"; fi
  [ "$r" = "$4" ] && ok="✓" || ok="✗"
  printf "%s %-13s -> %-13s %-5s  %-10s %s\n" "$ok" "$1" "$2" "$3" "$r" "$5"
}
echo "# Pruebas de conexion TCP entre segmentos (nc -z -w 2)"
echo "  ORIGEN           DESTINO        PUERTO RESULTADO  REGLA"
t wan-atacante 10.10.10.20  80   PERMITIDO "R1  web publicada en la DMZ"
t wan-atacante 10.10.20.100 22   BLOQUEADO "R3  Internet no entra a la red interna"
t wan-atacante 10.10.20.50  3306 BLOQUEADO "R3  Internet no llega a la BD"
t dmz-api      10.10.20.50  3306 PERMITIDO "R4  unica excepcion DMZ->interna (API->BD)"
t dmz-web      10.10.20.50  3306 BLOQUEADO "R5  servidor web comprometido no pivotea"
t dmz-web      10.10.30.10  80   BLOQUEADO "R5b DMZ no llega a IoT"
t iot-cam      10.10.20.100 445  BLOQUEADO "R7  IoT aislado de la red interna"
t iot-cam      10.10.10.20  80   BLOQUEADO "R7  IoT aislado de la DMZ"
t iot-cam      203.0.113.80 443  PERMITIDO "R6  IoT habla con su nube por HTTPS"
t iot-cam      203.0.113.80 80   BLOQUEADO "R7b IoT sin otros puertos"
t int-pc       10.10.10.20  80   PERMITIDO "R10 usuarios internos usan la web de la DMZ"
t int-pc       10.10.30.10  80   BLOQUEADO "R9b interna no inicia conexiones a IoT"
