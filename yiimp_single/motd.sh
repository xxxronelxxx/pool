#!/usr/bin/env bash

#####################################################
# Created by Afiniel for Yiimpool use...
#####################################################

# Source necessary configuration files
source /etc/functions.sh
source /etc/yiimpool.conf

print_header "MOTD Configuration Setup"

print_status "Installing required MOTD packages"
apt_install lsb-release update-motd landscape-common update-notifier-common

print_status "Configuring MOTD for your system"
if [[ $DISTRO = "16" || $DISTRO = "17" || $DISTRO = "18" || $DISTRO = "19" || $DISTRO = "20" || $DISTRO = "21" || $DISTRO = "22" || $DISTRO = "23" || $DISTRO = "24" ]]; then
    print_info "Setting up MOTD for Ubuntu"
    cd $HOME/Yiimpoolv1/yiimp_single/ubuntu/etc/update-motd.d
    sudo rm -rf /etc/update-motd.d/
    sudo mkdir /etc/update-motd.d/
    sudo cp -r {00-header,10-sysinfo,90-footer} /etc/update-motd.d/
    sudo chmod +x /etc/update-motd.d/*
    print_success "Ubuntu MOTD configuration completed"

elif [[ $DISTRO = "12" || $DISTRO = "11" ]]; then
    print_info "Setting up MOTD for Debian"
    cd $HOME/Yiimpoolv1/yiimp_single/debian/etc/update-motd.d
    sudo rm -rf /etc/update-motd.d/
    sudo mkdir /etc/update-motd.d/
    sudo cp -r {00-header,10-sysinfo,90-footer} /etc/update-motd.d/
    sudo chmod +x /etc/update-motd.d/*
    print_success "Debian MOTD configuration completed"
fi

print_status "Installing system management scripts"
sudo cp -r $HOME/Yiimpoolv1/yiimp_single/ubuntu/screens /usr/bin/
sudo chmod +x /usr/bin/screens
sudo cp -r $HOME/Yiimpoolv1/yiimp_single/ubuntu/stratum /usr/bin/
sudo chmod +x /usr/bin/stratum


echo '
clear
run-parts /etc/update-motd.d/ | sudo tee /etc/motd
' | sudo -E tee /usr/bin/motd >/dev/null 2>&1
sudo chmod +x /usr/bin/motd

print_success "MOTD setup completed successfully"

cd $HOME/Yiimpoolv1/yiimp_single
