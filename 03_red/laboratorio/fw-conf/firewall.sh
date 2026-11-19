#!/bin/bash
# Reglas de minimo privilegio (equivalentes a pfsense-rules.xml R1-R12)
WAN=203.0.113.0/24; DMZ=10.10.10.0/24; INT=10.10.20.0/24; IOT=10.10.30.0/24; VPN=10.10.99.0/24
RFC1918="10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"
iptables -F FORWARD; iptables -P FORWARD DROP
A() { iptables -A FORWARD "$@"; }
A -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT                                   -m comment --comment "retorno de sesiones"
A -s $WAN -d 10.10.10.20 -p tcp -m multiport --dports 80,443 -j ACCEPT                   -m comment --comment "R1 WAN->DMZ web publicada"
A -s $WAN -d 10.10.10.30 -p tcp --dport 3000 -j ACCEPT                                   -m comment --comment "R1 WAN->DMZ API publicada"
A -s $VPN -d $INT -m policy --dir in --pol ipsec -p tcp -m multiport --dports 22,443,445,3389 -j ACCEPT -m comment --comment "R11 VPN->INTERNA puertos minimos"
A -s $VPN -j DROP                                                                        -m comment --comment "R12 VPN resto denegado"
A -s $WAN -d $INT -j DROP                                                                -m comment --comment "R3 WAN->INTERNA bloqueado"
A -s 10.10.10.30 -d 10.10.20.50 -p tcp --dport 3306 -j ACCEPT                            -m comment --comment "R4 solo API->BD"
A -s $DMZ -d $INT -j DROP                                                                -m comment --comment "R5 DMZ->INTERNA bloqueado"
A -s $DMZ -d $IOT -j DROP                                                                -m comment --comment "R5b DMZ->IoT bloqueado"
for n in $RFC1918; do A -s $IOT -d $n -j DROP                                            -m comment --comment "R7 IoT->redes privadas bloqueado"; done
A -s $IOT -p tcp -m multiport --dports 443,8883 -j ACCEPT                                -m comment --comment "R6 IoT solo HTTPS/MQTT-TLS"
A -s $IOT -j DROP                                                                        -m comment --comment "R7b IoT resto bloqueado"
A -s $INT -d $IOT -j DROP                                                                -m comment --comment "R9b INTERNA->IoT bloqueado"
A -s $INT -p tcp -m multiport --dports 80,443,3000 -j ACCEPT                             -m comment --comment "R10 INTERNA navegacion y API"
A -s $INT -p icmp --icmp-type echo-request -j ACCEPT                                     -m comment --comment "INTERNA ping de diagnostico"
