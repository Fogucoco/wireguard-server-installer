#!/bin/bash

# root check
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root " 
    exit 1
fi

# updates
apt update -y
apt upgrade -y
apt autoremove -y

# installing dependancies
apt install wget -y
apt install curl -y
apt install ufw -y

# ufw configuration
ufw allow ssh
ufw allow 51820
yes y | ufw enable

# wireguard installation and configuration
apt install wireguard -y
echo -e "\nnet.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

chmod /etc/wireguard 700
mkdir /etc/wireguard/server-keys

private_key=$(wg genkey)
public_key=$(echo $private_key | wg pubkey)
echo "$private_key" > /etc/wireguard/server-keys/private.key
echo "$public_key" > /etc/wireguard/server-keys/public.key

wg0="[Interface]
PrivateKey = $private_key
Address = 10.0.0.1/24
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
ListenPort = 51820
"
echo "$wg0" > /etc/wireguard/wg0.conf

# vpn user creation
echo 2 > /etc/wireguard/user-count

wget https://raw.githubusercontent.com/Fogucoco/wireguard-server-installer/refs/heads/main/add-wg-user.sh
chmod +x add-wg-user.sh

./add-wg-user.sh

wg-quick up wg0
