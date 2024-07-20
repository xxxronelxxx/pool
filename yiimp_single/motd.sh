#!/usr/bin/env bash

#####################################################
# Created by Afiniel for Yiimpool use...
#####################################################

# Source necessary configuration files
source /etc/functions.sh
source /etc/yiimpool.conf

# Install required packages
apt_install lsb-release figlet update-motd landscape-common update-notifier-common

# Set up/update MOTD (Message of the Day)
cd "$HOME/Yiimpoolv1/yiimp_single/ubuntu/etc/update-motd.d"
sudo rm -rf /etc/update-motd.d/
sudo mkdir /etc/update-motd.d/
sudo cp -r {00-header,10-sysinfo,90-footer} /etc/update-motd.d/
sudo chmod +x /etc/update-motd.d/*

# Copy additional scripts to system binaries
sudo cp -r "$HOME/Yiimpoolv1/yiimp_single/ubuntu/screens" /usr/bin/
sudo chmod +x /usr/bin/screens
sudo cp -r "$HOME/Yiimpoolv1/yiimp_single/ubuntu/stratum" /usr/bin/
sudo chmod +x /usr/bin/stratum

# Create and configure custom motd command
echo '
clear
run-parts /etc/update-motd.d/ | sudo tee /etc/motd
' | sudo -E tee /usr/bin/motd >/dev/null 2>&1
sudo chmod +x /usr/bin/motd

cd $HOME/Yiimpoolv1/yiimp_single
