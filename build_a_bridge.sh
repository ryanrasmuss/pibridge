#!/bin/bash

# Greeting

echo -e "\033[5mGreetz!\033[0m"

# make sure root

if [ $(id -u) != 0 ]; then
    echo "Please run as root!"
    exit 1
fi

# ask for inbound interface and outbound interface

if [ $# != 2 ]; then
    echo -e "\n\tUsage: ./build_a_bridge.sh <inbound interface name> <outbound interface name>"
    echo -e "\tExample: ./build_a_bridge.sh <eth0> <wlan0>\n"
    exit 1
fi

# test address script for compat

LEN=`expr ${#2} + 1`

ADDRESS=$(``ifconfig $2 | grep "inet" | awk 'NR==1{print $2}' | cut -c $LEN-``)

read -p "Is this your $2 ip address $ADDRESS (y/n)? " choice

if [ -z $choice ]; then
    echo "Don't mess with me."
    exit 0
fi

if [ $choice != "y" ]; then
    echo "Sorry, problem fetching ip :("
    echo "We need to break up.."
    echo "It's not you, it's me."
    exit 0
fi

# save interfaces

interfaces_config=/etc/network/iptables/interfaces_config
# rewrite current config, if one exists
echo $1 > $interfaces_config
echo $2 >> $interfaces_config

# backup the current iptables

iptables-save > before_bridge.iptables.save
echo "If things break, run: iptables-restore < before_bridge.iptables.save"

# move the service script and auto_bridge.sh

cp -v pibridge.sh /etc/
cp -v pibridge.service /etc/systemd/system/

# systemctl calls

systemctl daemon-reload
systemctl enable pibridge.service

# Ask for reboot

echo "Please reboot" 
