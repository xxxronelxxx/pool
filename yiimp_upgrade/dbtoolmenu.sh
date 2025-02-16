#!/bin/env bash

#####################################################
# Created by Afiniel for Yiimpool use
#
# This is the Database Tool Menu for Yiimpool
#
# Author: Afiniel
# Updated: 2025-02-16
#####################################################

source /etc/yiimpooldonate.conf
source /etc/functions.sh
source /etc/yiimpoolversion.conf

term_art
print_header "Database Import Menu"

print_status "Importing YiiMP database values..."


RESULT=$(dialog --stdout --title "Database Tool Menu" --menu "Choose an option" 16 60 9 \
    1 "Database Import" \
    2 "Exit")

case "$RESULT" in
    1)
        clear
        cd $HOME/Yiimpoolv1/yiimp_upgrade
        source db.sh
        ;;
    2)
        clear
        motd
        echo -e "${GREEN}Exiting Database Import Menu${NC}"
        echo -e "${YELLOW}Type 'yiimpool' anytime to return to the menu${NC}"
        exit 0
        ;;
    *   )
        show_menu
        ;;
esac
