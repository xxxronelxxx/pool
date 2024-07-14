#!/bin/env bash

##################################################################################
# This is the entry point for configuring the system.                            #
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox   #
# Updated by Afiniel for yiimpool use...                                         #
# Date 2024-07-13                                                                #
# Update 2024-07-14
##################################################################################

source /etc/functions.sh
cd ~/yiimpoolv2/install || { echo "Failed to change directory to ~/yiimpoolv2/install"; exit 1; }
clear

# Get the current logged in username
current_user=$(whoami)
echo -e "${YELLOW}Modifying existing user ${MAGENTA}$current_user${YELLOW} for yiimpool support.$NC"

# Add current user to the sudo group
sudo usermod -aG sudo "$current_user"

# Configure passwordless sudo for the current user
sudo bash -c "cat <<EOF > /etc/sudoers.d/$current_user
# yiimp
# It needs passwordless sudo functionality.
$current_user ALL=(ALL) NOPASSWD:ALL
EOF"

# Create a helper script to start yiimpool setup
sudo bash -c "cat <<EOF > /usr/bin/yiimpool
cd ~/yiimpoolv2/install
bash start.sh
EOF"
sudo chmod +x /usr/bin/yiimpool

# Check required files and set global variables
source pre_setup.sh || { echo "Failed to source pre_setup.sh"; exit 1; }

# Create the STORAGE_USER and STORAGE_ROOT directory if they don't already exist
if ! id -u "$STORAGE_USER" >/dev/null 2>&1; then
    sudo useradd -m "$STORAGE_USER"
fi
if [ ! -d "$STORAGE_ROOT" ]; then
    sudo mkdir -p "$STORAGE_ROOT"
fi

echo 'STORAGE_USER='"${STORAGE_USER}"'
STORAGE_ROOT='"${STORAGE_ROOT}"'
PUBLIC_IP='"${PUBLIC_IP}"'
PUBLIC_IPV6='"${PUBLIC_IPV6}"'
DISTRO='"${DISTRO}"'
FIRST_TIME_SETUP='"${FIRST_TIME_SETUP}"'
PRIVATE_IP='"${PRIVATE_IP}"'' | sudo -E tee /etc/yiimpool.conf >/dev/null 2>&1

# Setting Donor Addresses
    echo 'BTCDON="bc1qc4qqz8eu5j7u8pxfrfvv8nmcka7whhm225a3f9"
    LTCDON="ltc1qma2lgr2mgmtu7sn6pzddaeac9d84chjjpatpzm"
    ETHDON="0xdA929d4f03e1009Fc031210DDE03bC40ea66D044"
    BCHDON="qpse55j0kg0txz0zyx8nsrv3pvd039c09ypplsfn87"
    DOGEDON="DFPg3VnH4kTbWiejpwsXvq1sP9qbuwYe6Z"' | sudo tee /etc/yiimpooldonate.conf >/dev/null || { echo "Failed to create /etc/yiimpooldonate.conf"; exit 1; }

# Set file access control lists (ACLs)
sudo setfacl -m u:"$current_user":rwx /home/"$current_user"/yiimpoolv2

# Clear the screen and display a message to the user
clear
echo
echo -e "${YELLOW}Detected the following information:$NC"
echo
echo -e "${MAGENTA}USERNAME: ${GREEN}$current_user$NC"
echo -e "${MAGENTA}STORAGE_USER: ${GREEN}${STORAGE_USER}$NC"
echo -e "${MAGENTA}STORAGE_ROOT: ${GREEN}${STORAGE_ROOT}$NC"
echo -e "${MAGENTA}PUBLIC_IP: ${GREEN}${PUBLIC_IP}$NC"
echo -e "${MAGENTA}PUBLIC_IPV6: ${GREEN}${PUBLIC_IPV6}$NC"
echo -e "${MAGENTA}DISTRO: ${GREEN}${DISTRO}$NC"
echo -e "${MAGENTA}FIRST_TIME_SETUP: ${GREEN}${FIRST_TIME_SETUP}$NC"
echo -e "${MAGENTA}PRIVATE_IP: ${GREEN}${PRIVATE_IP}$NC"
echo
echo -e "${GREEN}Your user: ${MAGENTA}$current_user${GREEN} has been modified for yiimpool support.$NC"
echo -e "${YELLOW}You must ${RED}reboot${YELLOW} the system for the new permissions to update.$NC"
echo -e "${YELLOW}After reboot, type ${GREEN}yiimpool${YELLOW} to continue setup.$NC"
exit 0
