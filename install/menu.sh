#!/usr/bin/env bash

################################################################################
# Yiimpool Menu Script                                                         #
#                                                                              #
# Author: Afiniel                                                              #
# Updated: 2024-07-13                                                          #
################################################################################

# Source necessary configuration files and functions
source /etc/yiimpooldonate.conf
source /etc/functions.sh

# Display menu using dialog
RESULT=$(dialog --stdout --nocancel --default-item 1 --title "Yiimpool Menu $VERSION" --menu "Choose an option" -1 55 7 \
    ' ' "- Install Yiimp -" \
    1 "Install Yiimp Single Server" \
    ' ' "- Upgrade Yiimp Stratum -" \
    2 "Upgrade Stratum" \
    3 "Exit")

# Process user selection
case "$RESULT" in
    1)
        clear
        echo "Installing Yiimp Single Server..."
        cd "$HOME/yiimpoolv2/yiimp_single"
        source start.sh
        ;;
    2)
        clear
        echo "Upgrading Yiimp Stratum..."
        cd "$HOME/yiimpoolv2/yiimp_upgrade"
        source start.sh
        ;;
    3)
        clear
        echo "Exiting Yiimpool Menu."
        exit 0
        ;;
    *)
        clear
        echo "Invalid option. Exiting Yiimpool Menu."
        exit 1
        ;;
esac
