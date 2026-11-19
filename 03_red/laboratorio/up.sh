#!/bin/bash
# Laboratorio de segmentacion: 3 VLAN + WAN, firewall con minimo privilegio y VPN IPsec
set -e
D="$(cd "$(dirname "$0")" && pwd)"
for c in fw dmz-web dmz-api int-pc int-db iot-cam wan-atacante wan-nube vpn-cliente; do docker rm -f $c >/dev/null 2>&1 || true; done
for n in seg-wan seg-dmz seg-int seg-iot; do docker network rm $n >/dev/null 2>&1 || true; done
docker network create --subnet 203.0.113.0/24 --gateway 203.0.113.254 seg-wan >/dev/null
docker network create --subnet 10.10.10.0/24 --gateway 10.10.10.254 seg-dmz >/dev/null
docker network create --subnet 10.10.20.0/24 --gateway 10.10.20.254 seg-int >/dev/null
docker network create --subnet 10.10.30.0/24 --gateway 10.10.30.254 seg-iot >/dev/null

# Firewall / router (hace el papel de pfSense)
docker create --name fw --hostname fw --cap-add NET_ADMIN --sysctl net.ipv4.ip_forward=1 \
  --network seg-wan --ip 203.0.113.1 -v "$D/fw-conf:/conf:ro" lab4-host sleep infinity >/dev/null
docker network connect --ip 10.10.10.1 seg-dmz fw
docker network connect --ip 10.10.20.1 seg-int fw
docker network connect --ip 10.10.30.1 seg-iot fw
docker start fw >/dev/null

host() { # nombre red ip gateway comando-servicio
  docker run -d --name $1 --hostname $1 --cap-add NET_ADMIN --network $2 --ip $3 lab4-host \
    bash -c "ip route replace default via $4; $5 sleep infinity" >/dev/null
}
L() { echo "for p in $*; do python3 -c \"import socket,sys;s=socket.socket();s.setsockopt(socket.SOL_SOCKET,socket.SO_REUSEADDR,1);s.bind(('',\$p));s.listen(9)
while 1: s.accept()[0].close()\" & done;"; }
host dmz-web seg-dmz 10.10.10.20 10.10.10.1 "python3 -m http.server 80 >/dev/null 2>&1 &"
host dmz-api seg-dmz 10.10.10.30 10.10.10.1 "$(L 3000)"
host int-pc  seg-int 10.10.20.100 10.10.20.1 "$(L 22 445 3389)"
host int-db  seg-int 10.10.20.50 10.10.20.1 "$(L 3306)"
host iot-cam seg-iot 10.10.30.10 10.10.30.1 ""
host wan-atacante seg-wan 203.0.113.50 203.0.113.1 ""
host wan-nube seg-wan 203.0.113.80 203.0.113.1 "$(L 443 8883 80)"
docker run -d --name vpn-cliente --hostname vpn-cliente --cap-add NET_ADMIN --network seg-wan --ip 203.0.113.60 \
  -v "$D/cli-conf:/conf:ro" lab4-host sleep infinity >/dev/null

# Reglas de firewall + VPN en fw
docker exec fw bash /conf/firewall.sh
docker exec fw bash -c 'cp /conf/ipsec.conf /etc/ipsec.conf; cp /conf/ipsec.secrets /etc/ipsec.secrets; chmod 600 /etc/ipsec.secrets; ipsec start >/dev/null 2>&1'
docker exec vpn-cliente bash -c 'cp /conf/ipsec.conf /etc/ipsec.conf; cp /conf/ipsec.secrets /etc/ipsec.secrets; chmod 600 /etc/ipsec.secrets'
echo "laboratorio listo"
