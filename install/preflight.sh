#!/usr/bin/env bash

##################################################################################
# Preflight script for configuring the system for Yiimpool installation.         #
#                                                                                #
# Author: Afiniel                                                                #
# Date: 2024-07-14                                                               #
##################################################################################

# Source functions from another script
source /etc/functions.sh

echo -e "${YELLOW}Starting preflight checks...${NC}"
echo

# Define supported Ubuntu LTS versions
SUPPORTED_UBUNTU_VERSIONS=("20.04" "20.04.6" "18.04" "16.04")

# Function to check if a Ubuntu LTS version is supported
check_ubuntu_version() {
    lsb_release -ds | grep -q "Ubuntu $1 LTS"
}

# Function to ensure directories are not group writable
secure_directories() {
    echo -e "${YELLOW}Securing system directories...${NC}"
    sudo chmod g-w /etc /etc/default /usr
    echo -e "${GREEN}System directories secured.${NC}"
}

# Function to check if swap is needed
check_swap_needed() {
    local SWAP_MOUNTED=$(grep -e "^/swapfile" /proc/swaps)
    local SWAP_IN_FSTAB=$(grep -e "^/swapfile" /etc/fstab)
    local ROOT_IS_BTRFS=$(grep -e "\/ .*btrfs" /proc/mounts)
    local TOTAL_PHYSICAL_MEM=$(awk '/MemTotal/{print $2}' /proc/meminfo)
    local AVAILABLE_DISK_SPACE=$(df / --output=avail | tail -n 1)

    # Check conditions for needing swap
    if [ -z "$SWAP_MOUNTED" ] && [ -z "$SWAP_IN_FSTAB" ] && [ ! -e /swapfile ] && \
       [ -z "$ROOT_IS_BTRFS" ] && [ "$TOTAL_PHYSICAL_MEM" -lt 1536000 ] && \
       [ "$AVAILABLE_DISK_SPACE" -gt 5242880 ]; then
        return 0  # Swap is needed
    else
        return 1  # Swap is not needed
    fi
}

# Function to create swap file
create_swap() {
    echo
    echo -e "${YELLOW}Adding a swap file to the system...${NC}"
    sudo fallocate -l 3G /swapfile
    if [ -e /swapfile ]; then
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        # Add swap entry to /etc/fstab and adjust swappiness
        echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab >/dev/null
        echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf >/dev/null
        echo -e "${GREEN}Swap file added successfully.${NC}"
    else
        echo -e "${RED}ERROR: Swap allocation failed.${NC}"
    fi
}

echo
echo -e "${YELLOW}Starting system configuration...${NC}"

# Check if the Ubuntu version is supported
for VERSION in "${SUPPORTED_UBUNTU_VERSIONS[@]}"; do
    if check_ubuntu_version "$VERSION"; then
        DISTRO="$VERSION"
        echo -e "${GREEN}Detected Ubuntu $DISTRO LTS.${NC}"
        break
    fi
done

# Exit if the Ubuntu version is not supported
if [ -z "$DISTRO" ]; then
    echo -e "${RED}This script only supports Ubuntu ${SUPPORTED_UBUNTU_VERSIONS[*]} LTS.${NC}"
    exit 1
fi

# Secure system directories
secure_directories

# Check and create swap if needed
if check_swap_needed; then
    create_swap
fi

# Check architecture compatibility (only supports x86_64)
if [ "$(uname -m)" != "x86_64" ]; then
    echo -e "${RED}Yiimpool Installer only supports x86_64 architecture.${NC}"
    echo -e "${RED}Your architecture is $(uname -m)${NC}"
    exit 1
fi

# Set default values for STORAGE_USER and STORAGE_ROOT if not already set
STORAGE_USER=${STORAGE_USER:-crypto-data}
STORAGE_ROOT=${STORAGE_ROOT:-/home/$STORAGE_USER}

