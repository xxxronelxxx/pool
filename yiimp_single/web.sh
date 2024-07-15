#!/usr/bin/env bash

#####################################################
# This script sets up the web structure, copies necessary files, 
# modifies configuration files, and sets permissions for a YiiMP 
# cryptocurrency mining pool installation. It handles domain and 
# SSL configurations, updates the YiiMP build, and ensures the 
# correct permissions are applied to directories and files.
# 
# Updated by afiniel for crypto use.
# Author: afiniel
# Date: 2024-07-15
#####################################################

# Load configuration files
source /etc/functions.sh
source /etc/yiimpool.conf
source $STORAGE_ROOT/yiimp/.yiimp.conf
source $HOME/Yiimpoolv2/yiimp_single/.wireguard.install.cnf

set -euo pipefail

function print_error {
  local line file
  read -r line file <<<"$(caller)"
  echo "An error occurred in line $line of file $file:" >&2
  sed "${line}q;d" "$file" >&2
}
trap print_error ERR

term_art

#if [[ "$wireguard" == "true" ]]; then
#  source "$STORAGE_ROOT/yiimp/.wireguard.conf"
#fi

echo
echo -e "$MAGENTA     <--$YELLOW Building web file structure and copying files$MAGENTA -->${NC}"
echo
echo
echo -e "$CYAN => Building web file structure and copying files <= ${NC}"

# Paths
YIIMP_SETUP_DIR="$STORAGE_ROOT/yiimp/yiimp_setup/yiimp"
SITE_DIR="$STORAGE_ROOT/yiimp/site"
WEB_DIR="$YIIMP_SETUP_DIR/web"

cd $STORAGE_ROOT/yiimp/yiimp_setup/yiimp
# Update SiteController.php
sudo sed -i "s/myadmin/${AdminPanel}/" "$WEB_DIR/yaamp/modules/site/SiteController.php"

# Copy web files
sudo cp -r "$WEB_DIR" "$SITE_DIR"

# Copy binaries
sudo cp -r "$YIIMP_SETUP_DIR/bin/." /bin/

# Create necessary directories
sudo mkdir -p "/var/www/${DomainName}/html" /etc/yiimp "$SITE_DIR/backup/"

# Update yiimp configuration
sudo sed -i "s|ROOTDIR=/data/yiimp|ROOTDIR=${SITE_DIR}|g" /bin/yiimp

# Nginx setup based on domain and SSL options
if [[ ("$UsingSubDomain" == "y" || "$UsingSubDomain" == "Y" || "$UsingSubDomain" == "yes" || "$UsingSubDomain" == "Yes" || "$UsingSubDomain" == "YES") ]]; then
    cd $HOME/Yiimpoolv2/yiimp_single
    source nginx_subdomain_nonssl.sh
  if [[ ("$InstallSSL" == "y" || "$InstallSSL" == "Y" || "$InstallSSL" == "yes" || "$InstallSSL" == "Yes" || "$InstallSSL" == "YES") ]]; then
    cd $HOME/Yiimpoolv2/yiimp_single
    source nginx_subdomain_ssl.sh
  fi
else
    cd $HOME/Yiimpoolv2/yiimp_single
    source nginx_domain_nonssl.sh
  if [[ ("$InstallSSL" == "y" || "$InstallSSL" == "Y" || "$InstallSSL" == "yes" || "$InstallSSL" == "Yes" || "$InstallSSL" == "YES") ]]; then
    cd $HOME/Yiimpoolv2/yiimp_single
    source nginx_domain_ssl.sh
  fi
fi

echo
echo -e "$MAGENTA => Creating YiiMP configuration files <= ${NC}"
# Source yiimp configuration scripts
for script in keys.sh yiimpserverconfig.sh main.sh loop2.sh blocks.sh; do
  source "yiimp_confs/$script"
done
echo -e "$GREEN => Complete${NC}"

echo
echo -e "$YELLOW => Setting correct folder permissions <= ${NC}"
WHOAMI=$(whoami)
sudo usermod -aG www-data "$WHOAMI"
sudo usermod -aG crypto-data "$WHOAMI"
sudo usermod -aG crypto-data www-data

sudo find "$SITE_DIR" -type d -exec chmod 775 {} +
sudo find "$SITE_DIR" -type f -exec chmod 664 {} +

sudo chgrp www-data "$STORAGE_ROOT" -R
sudo chmod g+w "$STORAGE_ROOT" -R
echo -e "$GREEN => Complete${NC}"

cd $HOME/Yiimpoolv2/yiimp_single

# Updating YiiMP files for YiimpPool build
echo
echo -e "$YELLOW => Adding the yiimpool flare to YiiMP <= ${NC}"

# Apply sed replacements
for file in \
  "$SITE_DIR/web/yaamp/modules/site/index.php" \
  "$SITE_DIR/web/yaamp/models/db_coinsModel.php" \
  "$SITE_DIR/web/index.php" \
  "$SITE_DIR/web/runconsole.php" \
  "$SITE_DIR/web/run.php" \
  "$SITE_DIR/web/yaamp/yiic.php" \
  "$SITE_DIR/web/yaamp/modules/thread/CronjobController.php" \
  "$SITE_DIR/web/yaamp/core/backend/system.php"; do

  sudo sed -i "s/YII MINING POOLS/${DomainName} Mining Pool/g" "$file"
  sudo sed -i "s/domain/${DomainName}/g" "$file"
  sudo sed -i "s/Notes/AddNodes/g" "$file"
  sudo sed -i "s|serverconfig.php|${SITE_DIR}/configuration/serverconfig.php|g" "$file"
  sudo sed -i "s|/root/backup|${SITE_DIR}/backup|g" "$file"
  sudo sed -i "s/service \$webserver start/sudo service \$webserver start/g" "$file"
  sudo sed -i "s/service nginx stop/sudo service nginx stop/g" "$file"
done

# Update coin_form.php for wireguard if necessary
if [[ "$wireguard" == "true" ]]; then
  internalrpcip="${DBInternalIP%.*}.0/26"
  sudo sed -i "/# onlynet=ipv4/i\        echo \"rpcallowip=${internalrpcip}\\n\";" "$SITE_DIR/web/yaamp/modules/site/coin_form.php"
fi

echo -e "$GREEN Web build complete${NC}"

set +euo pipefail
cd $HOME/Yiimpoolv2/yiimp_single
