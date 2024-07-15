#!/usr/bin/env bash

#####################################################
# Created by Afiniel for crypto use
#
# This script configures and upgrades NGINX for a 
# YiiMP pool setup, and handles database tweaks.
#
# Author: Afiniel
# Date: 2024-07-15
#####################################################

# Load configuration files
source /etc/functions.sh
source /etc/yiimpool.conf
source "$STORAGE_ROOT/yiimp/.yiimp.conf"
source "$HOME/Yiimpoolv2/yiimp_single/.wireguard.install.cnf"

cd "$HOME/Yiimpoolv2/yiimp_single"

# Ensure the script exits on error and logs errors
set -eu -o pipefail

function print_error {
    read -r line file <<<$(caller)
    echo "An error occurred in line $line of file $file:" >&2
    sed "${line}q;d" "$file" >&2
}
trap print_error ERR

# Display banner
term_art
echo 
echo -e "$MAGENTA Database$YELLOW build and tweak$GREEN completed ${NC}"
echo 
echo -e "$GREEN Passwords can be found in$RED $STORAGE_ROOT/yiimp/.my.cnf ${NC}"

# Load WireGuard configuration if enabled
if [[ "$wireguard" == "true" ]]; then
    source "$STORAGE_ROOT/yiimp/.wireguard.conf"
fi

echo
echo -e "$YELLOW => Upgrading NGINX  <= ${NC}"

# Add NGINX repository and key, then update and install NGINX
echo "deb http://nginx.org/packages/mainline/ubuntu $(lsb_release -cs) nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list >/dev/null 2>&1

sudo curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add - >/dev/null 2>&1
hide_output sudo apt-get update
hide_output sudo apt-get install -y nginx

# Create necessary NGINX directories and copy configuration files
sudo mkdir -p /etc/nginx/yiimpool
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old
sudo cp nginx_confs/nginx.conf /etc/nginx/
sudo cp nginx_confs/general.conf /etc/nginx/yiimpool
sudo cp nginx_confs/php_fastcgi.conf /etc/nginx/yiimpool
sudo cp nginx_confs/security.conf /etc/nginx/yiimpool
sudo cp nginx_confs/letsencrypt.conf /etc/nginx/yiimpool

# Remove default NGINX site configs
sudo rm -f /etc/nginx/sites-enabled/default
sudo rm -f /etc/nginx/sites-available/default*

echo -e "$GREEN NGINX upgrade complete.${NC}"

# Restart NGINX and PHP services
restart_service nginx
restart_service php7.3-fpm

# Reset error handling
set +eu +o pipefail

# Return to the initial directory
cd "$HOME/Yiimpoolv2/yiimp_single"
