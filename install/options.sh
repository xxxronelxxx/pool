#!/bin/env bash

#####################################################
# Created by Afiniel for Yiimpool use
#
# This is the main upgrade menu for Yiimpool
#
# Author: Afiniel
# Updated: 2024-07-15
#####################################################

source /etc/yiimpooldonate.conf
source /etc/functions.sh
source /etc/yiimpoolversion.conf

# Colors
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

display_version_info() {
    echo -e "${YELLOW}Current Version: ${GREEN}$VERSION${NC}"
    echo -e "${YELLOW}Checking for updates...${NC}"

    cd $HOME/Yiimpoolv1
    sudo git fetch --tags
    LATEST_TAG=$(sudo git describe --tags `sudo git rev-list --tags --max-count=1`)
    
    if [ "$VERSION" != "$LATEST_TAG" ]; then
        echo -e "${GREEN}New version available: $LATEST_TAG${NC}"
        echo -e "${YELLOW}Would you like to update? (y/n)${NC}"
        read -r update_choice
        
        if [[ "$update_choice" =~ ^[Yy]$ ]]; then
            cd $HOME/Yiimpoolv1/yiimp_upgrade
            source upgrade.sh
        else
            echo -e "${YELLOW}Update skipped${NC}"
        fi
    else
        echo -e "${GREEN}You are running the latest version${NC}"
    fi
    echo
}

# Function to display the menu
show_menu() {
    display_version_info
    
    RESULT=$(dialog --stdout --title "YiimPool Upgrade Menu $VERSION" --menu "Choose an option" -1 60 9 \
        ' ' "═══════════ Upgrade Options ═══════════" \
        1 "Full System Upgrade (Recommended)" \
        2 "Upgrade Stratum Only" \
        3 "Upgrade Web Interface Only" \
        4 "Restore from Backup" \
        5 "System Health Check" \
        6 "View Update History" \
        7 "Exit")
    
    case "$RESULT" in
        1)
            clear
            echo -e "${YELLOW}Starting full system upgrade...${NC}"
            cd $HOME/Yiimpoolv1/yiimp_upgrade
            source upgrade.sh
            show_menu
            ;;
        2)
            clear
            echo -e "${YELLOW}Starting stratum upgrade...${NC}"
            cd $HOME/Yiimpoolv1/yiimp_upgrade
            source upgrade.sh --stratum-only
            exit 0
            ;;
        3)
            clear
            echo -e "${YELLOW}Starting web interface upgrade...${NC}"
            cd $HOME/Yiimpoolv1/yiimp_upgrade
            source upgrade.sh --web-only
            show_menu
            ;;
        4)
            clear
            #cd $HOME/Yiimpoolv1/yiimp_upgrade/utils
            #source restore.sh
            #show_menu
            echo "Not completed yet, sorry."
            exit 0
            ;;
        5)
            clear
            echo -e "${YELLOW}Running system health check...${NC}"
            cd $HOME/Yiimpoolv1/yiimp_upgrade
            source health_check.sh
            exit 0
            ;;
        6)
            clear
            echo -e "${YELLOW}Update History:${NC}"
            cd $HOME/Yiimpoolv1
            git log --pretty=format:"%h - %s (%cr) <%an>" --since="30 days ago"
            exit 0
            ;;
        7)
            clear
            echo -e "${GREEN}Exiting YiimPool Upgrade Menu${NC}"
            echo -e "${YELLOW}Type 'yiimpool' anytime to return to the menu${NC}"
            exit 0
            ;;
        *)
            show_menu
            ;;
    esac
}

# Start the menu
clear
show_menu
