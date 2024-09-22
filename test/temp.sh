#!/bin/sh

# Install necessary tools first
apt update
apt install -y net-tools
apt install -y git
apt install -y network-manager
apt install -y hostapd
systemctl unmask hostapd
systemctl enable NetworkManager
systemctl start NetworkManager

# Make sure we have the correct system time. We cheat by getting it from Google.
date --set="$(curl -I --silent  http://google.com/ | grep Date | cut -f 2- -d" ")"

# set the hostname
hostnamectl set-hostname attacker

# change to the directory containing the script
cd $( cd $(dirname $0) && pwd)

# rename the network interfaces (lan/wan/wlan)
printf "lan\tplatform-1c1b000.usb-usb-0:1:1.0\n" | while read iface path; do
cat << EOF > /etc/systemd/network/10-$iface.link
[Match]
Path=$path

[Link]
Name=$iface
EOF
done

cp NetworkManager.conf /etc/NetworkManager/NetworkManager.conf

# autoload some modules
printf "g_serial\nmac80211_hwsim\nbr_netfilter\n" > /etc/modules

# install necessary packages
apt update
DEBIAN_FRONTEND=noninteractive apt install -y python3-setuptools python3-dev python3-pip
DEBIAN_FRONTEND=noninteractive apt install -y libpcap-dev
DEBIAN_FRONTEND=noninteractive apt install -y iftop dnsmasq tcpdump ebtables redsocks macchanger
DEBIAN_FRONTEND=noninteractive apt install -y libffi-dev libssl-dev
DEBIAN_FRONTEND=noninteractive apt install -y python3-pypcap || pip3 install pypcap
DEBIAN_FRONTEND=noninteractive apt install -y python3-dpkt || pip3 install dpkt
DEBIAN_FRONTEND=noninteractive apt install -y python3-pyroute2 || pip3 install pyroute2
DEBIAN_FRONTEND=noninteractive apt install -y python3-iptables
DEBIAN_FRONTEND=noninteractive apt install -y python3-cffi || pip3 install cffi

# disable dnsmasq, it is only needed in the slimjim namespace
systemctl disable --now dnsmasq
