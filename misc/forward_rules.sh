#!/bin/bash

# Need to make sure running as root
# Need to add message to edit this file with correct info, then add 1 in arg to run
# Add persistence save file & pre-up to /etc/network/interfaces

input=wlan0
output=eth0

# Server Addresses (i.e Destination is Web Server/Git Server/w.e)
prod_server=xxx.xxx.xxx.xxx
router_priv_address=xxx.xxx.xxx.xxx
esxi_server=xxx.xxx.xxx.xxx

# ports
ssh_port=1337

route add -net xxx.xxx.xxx.0 netmask xxx.xxx.xxx.xxx gw xxx.xxx.xxx.xxx
# echo "up route add -net 169.254.236.0 netmask 255.255.255.0 gw 192.168.13.1" >> /etc/network/interfaces

# Accept and forward the SYN packet to establish connection
iptables -A FORWARD -i $input -o $output -p tcp --syn --dport 80 -m conntrack --ctstate NEW -j ACCEPT
# Accept and forward all other traffic follwoing the established connection
iptables -A FORWARD -i $input -o $output -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i $output -o $input -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# Add destination NAT
iptables -t nat -A PREROUTING -i $input -p tcp --dport 80 -j DNAT --to-destination $prod_server
# Add source nat so replies can actually come back
iptables -t nat -A POSTROUTING -o $output -p tcp --dport 80 -d $prod_server -j SNAT --to-source $router_priv_address

# Add forward/nat to vmware esxi server
iptables -A FORWARD -i $input -o $output -p tcp --syn --dport 443 -m conntrack --ctstate NEW -j ACCEPT
iptables -t nat -A PREROUTING -i $input -p tcp --dport 443 -j DNAT --to-destination $esxi_server
iptables -t nat -A POSTROUTING -o $output -p tcp --dport 443 -d $esxi_server -j SNAT --to-source $router_priv_address

# Add ssh to git server
# Translate any 22222 service to port 22 ssh for git
iptables -A FORWARD -i $input -o $output -p tcp --syn --dport $ssh_port -m conntrack --ctstate NEW -j ACCEPT
iptables -t nat -A PREROUTING -i $input -p tcp --dport $ssh_port -j DNAT --to-destination $prod_server
iptables -t nat -A POSTROUTING -o $output -p tcp --dport $ssh_port -d $prod_server -j SNAT --to-source $router_priv_address
