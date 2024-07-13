#!/bin/env bash

##################################################################################
# This is the entry point for configuring the system.                            #
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox   #
# Updated by Afiniel for yiimpool use...                                         #
# Date 2024-07-13                                                                #
##################################################################################

source /etc/functions.sh
cd ~/yiimpoolv2/install || { echo "Failed to change directory to ~/yiimpoolv2/install"; exit 1; }
clear

# Get the current logged in username
current_user=$(whoami)
echo -e "${YELLOW}Modifying existing user ${MAGENTA}$current_user${YELLOW} for yiimpool support.${COL_RESET}"

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

# Save the global options in /etc/yiimpool.conf
sudo bash -c "cat <<EOF > /etc/yiimpool.conf
STORAGE_USER=$STORAGE_USER
STORAGE_ROOT=$STORAGE_ROOT
PUBLIC_IP=$PUBLIC_IP
PUBLIC_IPV6=$PUBLIC_IPV6
DISTRO=$DISTRO
FIRST_TIME_SETUP=$FIRST_TIME_SETUP
PRIVATE_IP=$PRIVATE_IP
EOF"

# Set Donor Addresses
sudo bash -c "cat <<EOF > /etc/yiimpooldonate.conf
BTCDON=\"bc1qc4qqz8eu5j7u8pxfrfvv8nmcka7whhm225a3f9\"
LTCDON=\"ltc1qma2lgr2mgmtu7sn6pzddaeac9d84chjjpatpzm\"
ETHDON=\"0xdA929d4f03e1009Fc031210DDE03bC40ea66D044\"
BCHDON=\"qpse55j0kg0txz0zyx8nsrv3pvd039c09ypplsfn87\"
DOGEDON=\"DFPg3VnH4kTbWiejpwsXvq1sP9qbuwYe6Z\"
EOF"

# Set file access control lists (ACLs)
sudo setfacl -m u:"$current_user":rwx /home/"$current_user"/yiimpoolv2

# Clear the screen and display a message to the user
clear
echo -e "${GREEN}Your user: ${MAGENTA}$current_user${GREEN} has been modified for yiimpool support.${COL_RESET}"
echo -e "${YELLOW}You must ${RED}reboot${YELLOW} the system for the new permissions to update.${COL_RESET}"
echo -e "${YELLOW}After reboot, type ${GREEN}yiimpool${YELLOW} to continue setup.${COL_RESET}"

exit 0
