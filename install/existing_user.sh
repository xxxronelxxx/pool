#!/usr/bin/env bash

##################################################################################
# Entry point script for configuring the system for Yiimpool installation.       #
# Source: https://mailinabox.email/                                              #
# Updated by Afiniel for Yiimpool use.                                           #
# Date: 2024-07-14                                                               #
##################################################################################

# Color variables for output formatting
YELLOW=$'\e[1;33m'
MAGENTA=$'\e[1;35m'
GREEN=$'\e[1;32m'
RED=$'\e[1;31m'
NC=$'\e[0m' # No Color

# Source helper functions
source /etc/functions.sh || { echo "${RED}Failed to source /etc/functions.sh${NC}"; exit 1; }

# Change directory to Yiimpool installation directory
cd ~/Yiimpoolv2/install || { echo "${RED}Failed to change directory to ~/Yiimpoolv2/install${NC}"; exit 1; }
clear

# Get the current logged-in username
current_user=$(whoami)
echo -e "${YELLOW}Modifying existing user ${MAGENTA}$current_user${YELLOW} for Yiimpool support.${NC}"

# Add current user to the sudo group if not already added
sudo usermod -aG sudo "$current_user"

# Configure passwordless sudo for the current user
sudo bash -c "cat <<EOF > /etc/sudoers.d/$current_user
# Yiimpool setup - passwordless sudo
$current_user ALL=(ALL) NOPASSWD:ALL
EOF"

# Create a helper script to start Yiimpool setup
sudo bash -c "cat <<EOF > /usr/bin/yiimpool
cd ~/Yiimpoolv2/install
bash start.sh
EOF"
sudo chmod +x /usr/bin/yiimpool

# Source pre-setup script to check required files and set global variables
source pre_setup.sh || { echo "${RED}Failed to source pre_setup.sh${NC}"; exit 1; }

# Create STORAGE_USER if it doesn't exist
if ! id -u "$STORAGE_USER" >/dev/null 2>&1; then
    sudo useradd -m "$STORAGE_USER" || { echo "${RED}Failed to create user $STORAGE_USER${NC}"; exit 1; }
fi

# Create STORAGE_ROOT directory if it doesn't exist
if [ ! -d "$STORAGE_ROOT" ]; then
    sudo mkdir -p "$STORAGE_ROOT" || { echo "${RED}Failed to create directory $STORAGE_ROOT${NC}"; exit 1; }
fi

# Write configuration variables to /etc/yiimpool.conf
echo "STORAGE_USER=$STORAGE_USER
STORAGE_ROOT=$STORAGE_ROOT
PUBLIC_IP=$PUBLIC_IP
PUBLIC_IPV6=$PUBLIC_IPV6
DISTRO=$DISTRO
FIRST_TIME_SETUP=$FIRST_TIME_SETUP
PRIVATE_IP=$PRIVATE_IP" | sudo -E tee /etc/yiimpool.conf >/dev/null 2>&1 || { echo "${RED}Failed to write to /etc/yiimpool.conf${NC}"; exit 1; }

# Set donor addresses in /etc/yiimpooldonate.conf
echo 'BTCDON="bc1qc4qqz8eu5j7u8pxfrfvv8nmcka7whhm225a3f9"
LTCDON="ltc1qma2lgr2mgmtu7sn6pzddaeac9d84chjjpatpzm"
ETHDON="0xdA929d4f03e1009Fc031210DDE03bC40ea66D044"
BCHDON="qpse55j0kg0txz0zyx8nsrv3pvd039c09ypplsfn87"
DOGEDON="DFPg3VnH4kTbWiejpwsXvq1sP9qbuwYe6Z"' | sudo tee /etc/yiimpooldonate.conf >/dev/null || { echo "${RED}Failed to create /etc/yiimpooldonate.conf${NC}"; exit 1; }

# Set file access control lists (ACLs)
sudo setfacl -m u:"$current_user":rwx /home/"$current_user"/yiimpoolv2 || { echo "${RED}Failed to set ACLs for /home/$current_user/yiimpoolv2${NC}"; exit 1; }

# Clear the screen and display setup information
clear
echo
echo -e "${YELLOW}Detected the following information:${NC}"
echo
echo -e "${MAGENTA}USERNAME: ${GREEN}$current_user${NC}"
echo -e "${MAGENTA}STORAGE_USER: ${GREEN}$STORAGE_USER${NC}"
echo -e "${MAGENTA}STORAGE_ROOT: ${GREEN}$STORAGE_ROOT${NC}"
echo -e "${MAGENTA}PUBLIC_IP: ${GREEN}$PUBLIC_IP${NC}"
echo -e "${MAGENTA}PUBLIC_IPV6: ${GREEN}$PUBLIC_IPV6${NC}"
echo -e "${MAGENTA}DISTRO: ${GREEN}$DISTRO${NC}"
echo -e "${MAGENTA}FIRST_TIME_SETUP: ${GREEN}$FIRST_TIME_SETUP${NC}"
echo -e "${MAGENTA}PRIVATE_IP: ${GREEN}$PRIVATE_IP${NC}"
echo
echo -e "${GREEN}Your user: ${MAGENTA}$current_user${GREEN} has been modified for Yiimpool support.${NC}"
echo -e "${YELLOW}You must ${RED}reboot${YELLOW} the system for the new permissions to update.${NC}"
echo -e "${YELLOW}After reboot, type ${GREEN}yiimpool${YELLOW} to continue setup.${NC}"
exit 0
