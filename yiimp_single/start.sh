#!/bin/env bash

##################################################################################
# This is the entry point for configuring the system.                            #
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox   #
# Updated by Afiniel for yiimpool use...                                         #
##################################################################################

source /etc/yiimpoolversion.conf
source /etc/functions.sh
source /etc/yiimpool.conf

# Ensure Python reads/writes files in UTF-8. If the machine
# triggers some other locale in Python, like ASCII encoding,
# Python may not be able to read/write files. This is also
# in the management daemon startup script and the cron script.

if ! locale -a | grep en_US.utf8 > /dev/null; then
# Generate locale if not exists
hide_output locale-gen en_US.UTF-8
fi

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8

# Fix so line drawing characters are shown correctly in Putty on Windows. See #744.
export NCURSES_NO_UTF8_ACS=1

# Create the temporary installation directory if it doesn't already exist.
if [ ! -d $STORAGE_ROOT/yiimp/yiimp_setup ]; then
    sudo mkdir -p $STORAGE_ROOT/{wallets,yiimp/{yiimp_setup/log,site/{web,stratum,configuration,crons,log},starts}}
    sudo touch $STORAGE_ROOT/yiimp/yiimp_setup/log/installer.log
fi

if [[ "$DISTRO" == "24" || "$DISTRO" == "23" || "$DISTRO" == "22" ]]; then
    sudo chmod 755 /home/crypto-data/
fi

# Start the installation.
source menu.sh
source questions.sh
source $HOME/Yiimpoolv1/yiimp_single/.wireguard.install.cnf

if [[ ("$wireguard" == "true") ]]; then
  source wireguard.sh
fi

source system.sh
source self_ssl.sh
source db.sh
source nginx_upgrade.sh
source web.sh
bash stratum.sh
source compile_crypto.sh
#source daemon.sh

# TODO: Fix the wiregard.
# To let users start us yiimp on multi servers.´

# if [[ ("$UsingDomain" == "yes") ]]; then
# source send_mail.sh
# fi

source server_cleanup.sh
source motd.sh
source server_harden.sh
source $STORAGE_ROOT/yiimp/.yiimp.conf

clear

# Color definitions (feel free to customize these for your liking)
YIIMP_GREEN="\e[38;5;2m"     # Success Green
YIIMP_BLUE="\e[38;5;4m"     # Dark Blue (info)
YIIMP_YELLOW="\e[33m"       # Warning Yellow
YIIMP_RED="\e[31m"        # Error Red
YIIMP_WHITE="\e[37m"       # White (data)
YIIMP_RESET="\e[0m"

# Header line
YIIMP_HEADER="${YIIMP_GREEN}<--------------------------------------------------------------------------->${YIIMP_RESET}"

# Function to display messages in a consistent format
print_message() {
  echo -e "${YIIMP_HEADER}"
  echo -e "${YIIMP_GREEN}Thanks for using Yiimpool Installer ${YIIMP_BLUE}${VERSION}${YIIMP_GREEN} (by Afiniel!)!${YIIMP_RESET}"
  echo
  echo -e "${YIIMP_BLUE}To run this installer anytime, simply type: ${YIIMP_GREEN}yiimpool${YIIMP_RESET}"
  echo -e "${YIIMP_HEADER}"
  echo -e "${YIIMP_BLUE}Like the installer and want to support the project? Use these wallets:"
  echo -e "${YIIMP_HEADER}"
  echo -e "${YIIMP_WHITE}- BTC: ${BTCDON}"
  echo -e "${YIIMP_WHITE}- BCH: ${BCHDON}"
  echo -e "${YIIMP_WHITE}- ETH: ${ETHDON}"
  echo -e "${YIIMP_WHITE}- DOGE: ${DOGEDON}"
  echo -e "${YIIMP_WHITE}- LTC: ${LTCDON}"
  echo -e "${YIIMP_HEADER}"
  echo
  echo -e "${YIIMP_GREEN}Yiimp installation is now ${YIIMP_GREEN}complete!${YIIMP_RESET}"
  echo -e "${YIIMP_YELLOW}Please REBOOT your machine to finalize updates and set folder permissions.${YIIMP_YELLOW} YiiMP won't function until a reboot is performed.${YIIMP_RESET}"
  echo
  echo -e "${YIIMP_BLUE}After the first reboot, it may take up to 1 minute for the ${YIIMP_GREEN}main${YIIMP_BLUE}|${YIIMP_GREEN}loop2${YIIMP_BLUE}|${YIIMP_GREEN}blocks${YIIMP_BLUE}|${YIIMP_GREEN}debug${YIIMP_BLUE} screens to start."
  echo -e "${YIIMP_BLUE}If they show ${YIIMP_RED}stopped${YIIMP_BLUE} after 1 minute, type ${YIIMP_GREEN}motd${YIIMP_BLUE} to refresh the screen.${YIIMP_RESET}"
  echo
  echo -e "${YIIMP_BLUE}Access your ${YIIMP_GREEN}${AdminPanel} at ${YIIMP_BLUE}http://${DomainName}/site/${AdminPanel}${YIIMP_RESET}"
  echo
  echo -e "${YIIMP_RED}By default, all stratum ports are blocked by the firewall.${YIIMP_YELLOW} To allow a port, use ${YIIMP_GREEN}sudo ufw allow <port number>${YIIMP_YELLOW} from the command line.${YIIMP_RESET}"
  echo -e "${YIIMP_WHITE}Database usernames and passwords can be found in ${YIIMP_RED}$STORAGE_ROOT/yiimp/.my.cnf${YIIMP_RESET}"
}

term_yiimpool
print_message
exit 0
ask_reboot

