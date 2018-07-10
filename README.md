# PiBridge

### Overview

Creates a bridge between two interfaces on a Raspberry Pi (Jessie).

For example, forward all traffic from ``wlan0`` to ``eth0``.

### Prerequisites

1. ``iptables``

2. Configure your ``/etc/network/interfaces`` so that it is similar to to the following:

```bash
source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback

# inbound interfaces
allow-hotplug eth0
iface eth0 inet static
    address 192.168.5.1
    network 192.168.5.0
    netmask 255.255.255.0
    broadcast 192.168.5.255

# outbound interface (has internet)
auto wlan0
allow-hotplug wlan0
iface wlan0 inet dhcp
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
```

Just make sure you network configuration is wworking before running this script.

As long as your ``wap_supplicant.conf`` file configured is correctly. This script will automatically adapt to the new network and reconfigure itself upon boot.


### Installation

Run ``build_a_bridge.sh`` as root. The script will prompt you for the inbound interface name and outbound interface name.

Should do everything automatically, or do nothing at all! :)

That's it, you're done.

### What PiBridge does to your machine

- Creates ``/etc/network/iptables/interfaces_config``
- Creates backup iptables in working directory
- Adds ``pibridge.sh`` in ``/etc/``
- Adds ``pibridge.service`` in ``/etc/systemd/system/``
- Adds pre-up for iptables in ``/etc/network/interfaces`` (end of file)
- iptables file is saved in ``/etc/network/iptables/iptables_config.txt``
- ``lastip.txt`` is created in ``/etc/network/iptables/``
- ``/var/log/pibridge.log`` contains startup information for the service

### How to Remove

- run ``burn_a_bridge.sh``
- run ``iptables-restore < before_bridge.iptables.save`` 
- delete the ``pre-up`` line in your ``/etc/network/interfaces`` or your network config will not load

### Todo

- Need to test IP changes
- Need to watch size of log file
- Handle Error check for lastip being empty
- check for iptables installed and usable; otherwise tell how to install

### Mentions

This [author] (https://rbnrpi.wordpress.com/project-list/wifi-to-ethernet-adapter-for-an-ethernet-ready-tv/)
