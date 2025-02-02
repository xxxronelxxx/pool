#!/usr/bin/env bash

#####################################################
# Created by Afiniel for Yiimpool use...
#####################################################

# Source necessary configuration files
source /etc/functions.sh
source /etc/yiimpool.conf

# Install required packages
apt_install lsb-release update-motd landscape-common update-notifier-common

if [[ $DISTRO = "16" || $DISTRO = "17" || $DISTRO = "18" || $DISTRO = "19" || $DISTRO = "20" || $DISTRO = "21" || $DISTRO = "22" || $DISTRO = "23" || $DISTRO = "24" ]]; then
    cd $HOME/Yiimpoolv1/yiimp_single/ubuntu/etc/update-motd.d
    sudo rm -rf /etc/update-motd.d/
    sudo mkdir /etc/update-motd.d/
    sudo cp -r {00-header,10-sysinfo,90-footer} /etc/update-motd.d/
    sudo chmod +x /etc/update-motd.d/*

elif [[ $DISTRO = "12" || $DISTRO = "11" ]]; then
    cd $HOME/Yiimpoolv1/yiimp_single/debian/etc/update-motd.d
    sudo rm -rf /etc/update-motd.d/
    sudo mkdir /etc/update-motd.d/
    sudo cp -r {00-header,10-sysinfo,90-footer} /etc/update-motd.d/
    sudo chmod +x /etc/update-motd.d/*
fi

# Copy additional scripts to system binaries
sudo cp -r $HOME/Yiimpoolv1/yiimp_single/ubuntu/screens /usr/bin/
sudo chmod +x /usr/bin/screens
sudo cp -r $HOME/Yiimpoolv1/yiimp_single/ubuntu/stratum /usr/bin/
sudo chmod +x /usr/bin/stratum

# Create and configure custom motd command
echo '
clear
run-parts /etc/update-motd.d/ | sudo tee /etc/motd
' | sudo -E tee /usr/bin/motd >/dev/null 2>&1
sudo chmod +x /usr/bin/motd

cd $HOME/Yiimpoolv1/yiimp_single
