#!/bin/bash

# test script for auto_bridge.sh

location=/etc/network/iptables/lastip.txt
log=/var/log/auto_pibridge.log

# make sure root?

# make sure arg given?

# may not need to b.c. script run by service

if ! [ -e $location ]; then
    echo "$(date): lastip.txt does not exist" >> $log
    echo $1 >> $location
    echo "$(date): set 10.0.0.161" >> $log
    exit 0
fi

echo "$location exists"

address=$(``cat $location``)

if [ $address != $1 ]; then
    echo "$(date): $address does not match arg $1" >> $log
    echo "$(date): set $1" >> $log
    echo $1 > $location
    exit 0
fi

echo "$(date): nothing to do" >> $log
