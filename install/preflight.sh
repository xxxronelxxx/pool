#!/usr/bin/env bash

##################################################################################
# Preflight script for configuring the system for Yiimpool.                      #
#                                                                                #
# Author: Afiniel                                                                #
# Date: 2024-07-13                                                               #
##################################################################################

# Source functions (assuming it contains color definitions)
source /etc/functions.sh

echo -e "${YELLOW}Starting preflight checks...${COL_RESET}"
echo

# Check for supported Ubuntu versions
DISTRO=""
case "$(lsb_release -d | sed 's/.*:\s*//')" in
  "Ubuntu 20.04 LTS" | "Ubuntu 20.04" | "Ubuntu 20.04.6 LTS")
    DISTRO=20
    ;;
  "Ubuntu 18.04 LTS" | "Ubuntu 18.04")
    DISTRO=18
    ;;
  "Ubuntu 16.04 LTS" | "Ubuntu 16.04")
    DISTRO=16
    ;;
  *)
    echo -e "${RED}ERROR: This script supports only Ubuntu 16.04 LTS, 18.04 LTS, and 20.04 LTS.${COL_RESET}"
    exit 1
    ;;
esac

echo -e "${YELLOW}Updating permissions...${COL_RESET}"
# Update permissions
sudo chmod g-w /etc /etc/default /usr
echo -e "${GREEN}Permissions updated.${COL_RESET}"
echo

echo -e "${YELLOW}Checking swap requirements...${COL_RESET}"

# Check if swap is needed
SWAP_MOUNTED=$(cat /proc/swaps | tail -n+2)
SWAP_IN_FSTAB=$(grep "swap" /etc/fstab)
ROOT_IS_BTRFS=$(grep "\/ .*btrfs" /proc/mounts)
TOTAL_PHYSICAL_MEM=$(head -n 1 /proc/meminfo | awk '{print $2}')
AVAILABLE_DISK_SPACE=$(df / --output=avail | tail -n 1)

if [ -z "$SWAP_MOUNTED" ] && [ -z "$SWAP_IN_FSTAB" ] && [ ! -e /swapfile ] && \
   [ -z "$ROOT_IS_BTRFS" ] && [ "$TOTAL_PHYSICAL_MEM" -lt 1536000 ] && [ "$AVAILABLE_DISK_SPACE" -gt 5242880 ]; then
  echo -e "${YELLOW}Adding a swap file to the system...${COL_RESET}"

  # Allocate and activate the swap file
  sudo fallocate -l 3G /swapfile
  if [ -e /swapfile ]; then
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf

    # Check if swap is mounted and activate on boot
    if swapon -s | grep -q "\/swapfile"; then
      echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab
      echo
      echo -e "${GREEN}Swap file successfully added.${COL_RESET}"
    else
      echo
      echo -e "${RED}ERROR: Swap allocation failed.${COL_RESET}"
    fi
  else
    echo
    echo -e "${RED}ERROR: Failed to create swap file.${COL_RESET}"
  fi
else
  echo
  echo -e "${YELLOW}Swap is not needed or already configured.${COL_RESET}"
fi

echo -e "${YELLOW}Checking system architecture...${COL_RESET}"
echo
# Check architecture
ARCHITECTURE=$(uname -m)
if [ "$ARCHITECTURE" != "x86_64" ]; then
  echo -e "${RED}ERROR: Yiimpool Installer supports only x86_64 architecture.${COL_RESET}"
  echo -e "${RED}Your architecture is $ARCHITECTURE${COL_RESET}"
  exit 1
fi
echo -e "${YELLOW}Your architecture is $ARCHITECTURE${COL_RESET}"

# Set STORAGE_USER and STORAGE_ROOT to default values if not already set
STORAGE_USER=${STORAGE_USER:-${DEFAULT_STORAGE_USER:-crypto-data}}
STORAGE_ROOT=${STORAGE_ROOT:-${DEFAULT_STORAGE_ROOT:-/home/$STORAGE_USER}}

echo
echo -e "${GREEN}Preflight checks completed successfully.${COL_RESET}"
