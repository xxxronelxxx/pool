#!/bin/bash

##################################################################################
# This script performs the initial setup required before installing Yiimpool.    #
# It sets up necessary environment variables and checks system requirements.     #
##################################################################################

source /etc/functions.sh

clear

echo -e "${YELLOW}Starting pre-setup...${COL_RESET}"

# Define global variables
export STORAGE_USER="yiimpool"
export STORAGE_ROOT="/home/yiimpool/data"
export PUBLIC_IP=$(curl -s ifconfig.me)
export PUBLIC_IPV6=$(curl -s -6 ifconfig.me)
export DISTRO=$(lsb_release -d | awk '{print $2, $3, $4}')
export FIRST_TIME_SETUP="YES"
export PRIVATE_IP=$(hostname -I | awk '{print $1}')

# Display the detected information
echo -e "${GREEN}Detected the following information:${COL_RESET}"
echo -e "${MAGENTA}STORAGE_USER: ${GREEN}${STORAGE_USER}${COL_RESET}"
echo -e "${MAGENTA}STORAGE_ROOT: ${GREEN}${STORAGE_ROOT}${COL_RESET}"
echo -e "${MAGENTA}PUBLIC_IP: ${GREEN}${PUBLIC_IP}${COL_RESET}"
echo -e "${MAGENTA}PUBLIC_IPV6: ${GREEN}${PUBLIC_IPV6}${COL_RESET}"
echo -e "${MAGENTA}DISTRO: ${GREEN}${DISTRO}${COL_RESET}"
echo -e "${MAGENTA}FIRST_TIME_SETUP: ${GREEN}${FIRST_TIME_SETUP}${COL_RESET}"
echo -e "${MAGENTA}PRIVATE_IP: ${GREEN}${PRIVATE_IP}${COL_RESET}"

# Check for root user
if [ "$(id -u)" != "0" ]; then
  echo -e "${RED}This script must be run as root. Use sudo.${COL_RESET}"
  exit 1
fi

# Check for necessary commands
commands=(curl lsb_release awk)
for cmd in "${commands[@]}"; do
  if ! command -v $cmd &>/dev/null; then
    echo -e "${RED}Command ${MAGENTA}$cmd${RED} could not be found. Please install it before proceeding.${COL_RESET}"
    exit 1
  fi
done

# Create the STORAGE_USER if it doesn't exist
if ! id -u $STORAGE_USER >/dev/null 2>&1; then
  echo -e "${YELLOW}Creating user ${MAGENTA}$STORAGE_USER${YELLOW}...${COL_RESET}"
  useradd -m $STORAGE_USER
else
  echo -e "${GREEN}User ${MAGENTA}$STORAGE_USER${GREEN} already exists.${COL_RESET}"
fi

# Create the STORAGE_ROOT directory if it doesn't exist
if [ ! -d $STORAGE_ROOT ]; then
  echo -e "${YELLOW}Creating storage directory ${MAGENTA}$STORAGE_ROOT${YELLOW}...${COL_RESET}"
  mkdir -p $STORAGE_ROOT
else
  echo -e "${GREEN}Storage directory ${MAGENTA}$STORAGE_ROOT${GREEN} already exists.${COL_RESET}"
fi

# Save the global options in /etc/yiimpool.conf
echo -e "${YELLOW}Saving global options to ${MAGENTA}/etc/yiimpool.conf${YELLOW}...${COL_RESET}"
echo 'STORAGE_USER='"${STORAGE_USER}"'
STORAGE_ROOT='"${STORAGE_ROOT}"'
PUBLIC_IP='"${PUBLIC_IP}"'
PUBLIC_IPV6='"${PUBLIC_IPV6}"'
DISTRO='"${DISTRO}"'
FIRST_TIME_SETUP='"${FIRST_TIME_SETUP}"'
PRIVATE_IP='"${PRIVATE_IP}"'' | tee /etc/yiimpool.conf >/dev/null 2>&1

# Set Donor Addresses
echo -e "${YELLOW}Setting donor addresses...${COL_RESET}"
echo 'BTCDON="bc1qc4qqz8eu5j7u8pxfrfvv8nmcka7whhm225a3f9"
LTCDON="ltc1qma2lgr2mgmtu7sn6pzddaeac9d84chjjpatpzm"
ETHDON="0xdA929d4f03e1009Fc031210DDE03bC40ea66D044"
BCHDON="qpse55j0kg0txz0zyx8nsrv3pvd039c09ypplsfn87"
DOGEDON="DFPg3VnH4kTbWiejpwsXvq1sP9qbuwYe6Z"' | tee /etc/yiimpooldonate.conf >/dev/null 2>&1

echo -e "${GREEN}Pre-setup completed successfully.${COL_RESET}"
exit 0
