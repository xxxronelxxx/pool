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

show_menu() {  
    RESULT=$(dialog --stdout --title "YiimPool Upgrade Menu $VERSION" --menu "Choose an option" -1 60 8 \
        ' ' "═══════════ Upgrade Options ═══════════" \
        1 "Full System Upgrade (Recommended)" \
        2 "Upgrade Stratum Only" \
        3 "Restore from Backup" \
        4 "System Health Check" \
        5 "View Update History" \
        6 "Exit")
    
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
            #cd $HOME/Yiimpoolv1/yiimp_upgrade/utils
            #source restore.sh
            #show_menu
            echo "Not completed yet, sorry."
            exit 0
            ;;
        4)
            clear
            echo -e "${YELLOW}Running system health check...${NC}"
            cd $HOME/Yiimpoolv1/yiimp_upgrade
            source health_check.sh
            exit 0
            ;;
        5)
            clear
            echo -e "${YELLOW}Update History:${NC}"
            cd $HOME/Yiimpoolv1
            git log --pretty=format:"%h - %s (%cr) <%an>" --since="30 days ago"
            exit 0
            ;;
        6)
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
