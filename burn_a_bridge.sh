#!/bin/bash

# Greeting

echo "Hello!"

# make sure root

if [ $(id -u) != 0 ]; then
    echo "Please run as root!"
    exit 1
fi

echo -e "Removing bridge setup"

rm -v /etc/network/iptables/interfaces_config
rm -v /etc/pibridge.sh
rm -v /etc/systemd/system/pibridge.service
rm -v /var/log/pibridge.log
rm -v /etc/network/iptables/lastip.txt
rm -v /etc/network/iptables/iptables_config.txt

systemctl daemon-reload

echo -e "\033[5mRemember to remove pre-up in /etc/network/interfaces\033[0m"

echo "Feel free to reboot"
