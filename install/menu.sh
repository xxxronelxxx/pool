#!/bin/env bash

#
# YiimPool Menu Script
#
# Author: Afiniel
# Updated: 2023-03-16
#

# Load configuration and functions
source /etc/yiimpooldonate.conf
source /etc/functions.sh

# Display menu and capture user selection
RESULT=$(dialog --stdout --nocancel --default-item 1 --title "YiimPool Menu $VERSION" --menu "Choose an option" -1 55 7 \
    ' ' "- Install Yiimp -" \
    1 "Install Yiimp Single Server" \
    ' ' "- Upgrade Yiimp Stratum -" \
    2 "Upgrade Yiimp Stratum Server" \
    3 "Exit")

# Handle user selection
if [ "$RESULT" = "1" ]; then
    clear
    echo "Preparing to install Yiimp Single Server..."
    cd $HOME/Yiimpoolv2/yiimp_single
    source start.sh

elif [ "$RESULT" = "2" ]; then
    clear
    echo "Preparing to upgrade Yiimp Stratum Server..."
    cd $HOME/Yiimpoolv2/yiimp_upgrade
    source start.sh

elif [ "$RESULT" = "3" ]; then
    clear
    echo "Exiting YiimPool Menu."
    exit
fi
