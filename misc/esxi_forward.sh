#!/bin/bash

input=wlan0
output=eth0

router_priv_address=xxx.xxx.xxx.xxx
esxi_server=xxx.xxx.xxx.xxx
esxi_port=1337

iptables -A FORWARD -i $input -o $output -p tcp --syn --dport $esxi_port -m conntrack --ctstate NEW -j ACCEPT
iptables -t nat -A PREROUTING -i $input -p tcp --dport $esxi_port -j DNAT --to-destination $esxi_server:443
iptables -t nat -A POSTROUTING -o $output -p tcp --dport $esxi_port -d $esxi_server -j SNAT --to-source $router_priv_address
