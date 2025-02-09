#!/usr/bin/env bash

#####################################################
# Source various web sources:
# https://www.linuxbabe.com/ubuntu/enable-google-tcp-bbr-ubuntu
# https://www.cyberciti.biz/faq/linux-tcp-tuning/
# Created by Afiniel for Yiimpool use...
#####################################################

source /etc/functions.sh
source /etc/yiimpool.conf

print_header "Server Performance Optimization"

print_status "Installing required packages for performance tuning"
hide_output sudo apt install -y --install-recommends linux-generic-hwe-16.04
echo 'net.core.default_qdisc=fq' | hide_output sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_congestion_control=bbr' | hide_output sudo tee -a /etc/sysctl.conf

print_header "Network Stack Optimization"

print_status "Configuring network buffer sizes"
echo 'net.core.wmem_max=12582912' | hide_output sudo tee -a /etc/sysctl.conf
echo 'net.core.rmem_max=12582912' | hide_output sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_rmem= 10240 87380 12582912' | hide_output sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_wmem= 10240 87380 12582912' | hide_output sudo tee -a /etc/sysctl.conf

print_status "Optimizing TCP parameters"
echo 'net.ipv4.tcp_window_scaling = 1' | hide_output sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_timestamps = 1' | hide_output sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_sack = 1' | hide_output sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_no_metrics_save = 1' | hide_output sudo tee -a /etc/sysctl.conf
echo 'net.core.netdev_max_backlog = 5000' | hide_output sudo tee -a /etc/sysctl.conf

print_success "Server hardening and performance optimization completed successfully"

cd $HOME/Yiimpoolv1/yiimp_single
