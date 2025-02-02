#!/usr/bin/env bash

##########################################
# Created by Afiniel for Yiimpool use
#
# This script installs and configures WireGuard
# for secure VPN communication. It sets up
# necessary keys, configuration files, and
# ensures the service is started and enabled
# at boot.
#
# Author: Afiniel
# Date: 2024-07-15
##########################################

# Load configuration files
source $HOME/Yiimpoolv1/yiimp_single/.wireguard.install.cnf
source $STORAGE_ROOT/yiimp/.wireguard.conf
source $STORAGE_ROOT/yiimp/.wireguard_public.conf
source /etc/functions.sh
source /etc/yiimpool.conf

# Display banner
term_art
echo -e "$MAGENTA    <-------------------------->${NC}"
echo -e "$MAGENTA     <--$YELLOW Installing WireGuard$MAGENTA -->${NC}"
echo -e "$MAGENTA    <-------------------------->${NC}"

# Add WireGuard repository and install packages
if [[ "$DISTRO" == "16" || "$DISTRO" == "18" || "$DISTRO" == "20" || "$DISTRO" == "22" || "$DISTRO" == "24" ]]; then
    hide_output sudo add-apt-repository ppa:wireguard/wireguard -y
    hide_output sudo apt-get update
    hide_output sudo apt-get install wireguard-dkms wireguard-tools -y
fi

if [[ "$DISTRO" == "12" ]]; then
    hide_output sudo apt-get install -y wireguard
fi

# Generate WireGuard keys
wg_private_key=$(wg genkey)
wg_public_key=$(echo "$wg_private_key" | wg pubkey)

# Create WireGuard configuration file
wg_config="/etc/wireguard/wg0.conf"
sudo tee "$wg_config" >/dev/null <<EOL
[Interface]
PrivateKey = $wg_private_key
ListenPort = 6121
SaveConfig = true
Address = ${DBInternalIP}/24
EOL

# Start WireGuard and enable at boot
sudo systemctl start wg-quick@wg0
sudo systemctl enable wg-quick@wg0

# Allow incoming connections on WireGuard port
ufw_allow 6121

# Display WireGuard public key and IP
dbpublic="${PUBLIC_IP}"
mypublic="${wg_public_key}"
echo -e "Public IP: ${dbpublic}\nPublic Key: ${mypublic}" | sudo -E tee "$STORAGE_ROOT/yiimp/.wireguard_public.conf" >/dev/null 2>&1

echo
echo -e "$GREEN WireGuard setup completed $NC"

cd $HOME/yiimpool/yiimp_single
