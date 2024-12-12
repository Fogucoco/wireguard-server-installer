#!/bin/bash

# root check
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root " 
    exit 1
fi

read -p "How many users to create? " user_number

for ((i=0; i<user_number; i++))
do
    # checking user count
    user_count=$(cat user-count)
    user_folder="user${user_count}"
    user_path="/etc/wireguard/user$user_count"

    # getting server ip address
    $ip_addr=$(curl ipinfo.io/ip)

    # generating and reading keys
    private_key=$(wg genkey)
    public_key=$(echo $private_key | wg pubkey)
    server_public_key=$(cat /etc/wireguard/server-keys/public.key)

    # creating user folder and their config
    mkdir $user_path
    echo $private_key > $user_path/private.key
    echo $public_key > $user_path/public.key

    user_config="[Interface]
PrivateKey = $private_key
Address = 10.0.0.$user_count/32
DNS = 8.8.8.8

[Peer]
PublicKey = $server_public_key
Endpoint = ${ip_addr}:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 20"

    echo "$user_config" > $user_path/wg.conf

    # adding new user to the server config
    new_user_peer="
[Peer]
PublicKey = $public_key
AllowedIPs = 10.0.0.$user_count/32"

    echo "$new_user_peer" >> /etc/wireguard/wg0.conf
done

read -p "For new users to be enabled you must restart the service. All users will lose their connetion.
Restart wireguard service? (Y/n): " answer
answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
if [[ "$answer" == "y" || "$answer" == "" ]]; then
    systemctl restart wg-quick@wg0
else
    echo "You can restart the service later by running:
sudo systemctl restart wg-quick@wg0"
fi
