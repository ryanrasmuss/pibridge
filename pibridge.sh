#!/bin/bash

# stdout echos
## notes or unused

## Attempt to snatch the ip address of outbound interface
## ADDRESS=$(``ifconfig $2 | grep "inet" | awk 'NR==1{print $2}' | cut -c 6-``)

## Attempting to get interfaces
interfaces_config=/etc/network/iptables/interfaces_config
LOCAL=$(``cat $interfaces_config | awk 'NR==1{print $1}'``)
INET=$(``cat $interfaces_config | awk 'NR==2{print $1}'``)

## LOCAL=$(``cat /etc/network/iptables/interfaces_config | awk 'NR==1{print $1}'``)
## INET=$(``cat /etc/network/iptables/interfaces_config | awk 'NR==2{print $1}'``)

#echo "LOCAL INTERFACE: $LOCAL"
#echo "INET INTERFACE: $INET"
LEN=`expr ${#INET} + 1`

##ADDRESS=$(``ifconfig $INET | grep "inet" | awk 'NR==1{print $2}' | cut -c 6-``)
ADDRESS=$(``ifconfig $INET | grep "inet" | awk 'NR==1{print $2}' | cut -c $LEN-``)

#echo "ADDRESS: $ADDRESS"

## files
lastip_file=/etc/network/iptables/lastip.txt
config_file=/etc/network/iptables/iptables_config.txt
log_file=/var/log/pibridge.log
interfaces=/etc/network/interfaces

## iptables function
function setup_iptables {

    # echo "STARTING IPTABLES SETUP"

    IPT=/sbin/iptables
    ## THIS INTERFACE IS CLIENT SIDE
    LOCAL_IFACE=$LOCAL
    ## THIS INTERFACE IS SERVER SIDE
    INET_IFACE=$INET
    ## IP ADDRESS OF SERVER SIDE IP ADDRESS
    INET_ADDRESS=$ADDRESS
    ## Flush the tables
    $IPT -F INPUT
    $IPT -F OUTPUT
    $IPT -F FORWARD
    $IPT -t nat -P PREROUTING ACCEPT
    $IPT -t nat -P POSTROUTING ACCEPT
    $IPT -t nat -P OUTPUT ACCEPT
    ## Allow forwarding packets:
    $IPT -A FORWARD -p ALL -i $LOCAL_IFACE -o $INET_IFACE -j ACCEPT
    $IPT -A FORWARD -i $INET_IFACE -o $LOCAL_IFACE -m state --state ESTABLISHED,RELATED -j ACCEPT
    ## Packet masquerading
    ##$IPT -t nat -A POSTROUTING -o $LOCAL_IFACE -j MASQUERADE
    $IPT -t nat -A POSTROUTING -o $INET_IFACE -j SNAT --to-source $INET_ADDRESS
}

if ! [ -e $lastip_file ]; then
    echo "$(date): no previous setup" >> $log_file
    echo "$(date): INET: $INET" >> $log_file
    echo "$(date): LEN: $LEN" >> $log_file
    echo "$(date): ADDRESS: $ADDRESS" >> $log_file
    echo "$(date): echo $ADDRESS > $lastip_file" >> $log_file
    echo $ADDRESS > $lastip_file
    echo "$(date): set $ADDRESS" >> $log_file
    setup_iptables
    echo "$(date): completed bridge setup" >> $log_file
    # iptables-save > /etc/network/iptables/iptables_config.txt
    iptables-save > $config_file
    echo "$(date): created iptables_config.txt" >> $log_file
    echo "# Pre-up added by pibridge.sh" >> $interfaces
    echo "pre-up iptables-restore < $config_file" >> $interfaces
    echo "Added a pre-up in $interfaces" >> $log_file
    exit 0
fi

# Can create a error if lastip.txt is empty (shouldn't happen, so touch it)
touch $lastip_file
lastip=$(``cat $lastip_file``)

if [ $lastip != $ADDRESS ]; then
    echo "$(date): ip address has changed" >> $log_file
    echo $ADDRESS > $lastip_file
    echo "$(date): set $ADDRESS" >> $log_file
    setup_iptables
    echo "$(date): completed bridge setup" >> $log_file
    iptables-save > $config_file
    echo "$(date): created iptables_config.txt" >> $log_file
    exit 0
fi

echo "$(date): nothing to do" >> $log_file
