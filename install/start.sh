#!/usr/bin/env bash

##################################################################################
# This is the entry point for configuring the Yiimpoolv2 system.                 #
#                                                                                #
# Author: Afiniel                                                                #
# Date: 2024-07-14                                                               #
##################################################################################

set -e

# Paths and environment variables
YIIMPOOL_CONF="/etc/yiimpool.conf"
YIIMPOOL_DONATE_CONF="/etc/yiimpooldonate.conf"
YIIMPOOL_VERSION_CONF="/etc/yiimpoolversion.conf"
INSTALL_DIR="$HOME/Yiimpoolv2/install"

# Function to log errors
log_error() {
    echo "[ERROR] $1" >&2
}

# Function to check and install dependencies
install_dependencies() {
    echo "Installing required dependencies..."
    sudo apt-get update
    sudo apt-get -y install figlet lolcat dialog python3 python3-pip acl nano git apt-transport-https || {
        log_error "Failed to install dependencies. Exiting."
        exit 1
    }
    echo "Dependencies installed."
}

# Function to set UTF-8 locale if not already set
set_utf8_locale() {
    if ! locale -a | grep -q en_US.utf8; then
        echo "Generating en_US.UTF-8 locale..."
        sudo locale-gen en_US.UTF-8
        sudo update-locale LANG=en_US.UTF-8
    fi
    export LANGUAGE=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
    export LC_TYPE=en_US.UTF-8
    export NCURSES_NO_UTF8_ACS=1
}

# Function to copy files to system directories
copy_files() {
    echo "Copying necessary files..."
    sudo cp "$INSTALL_DIR/functions.sh" /etc/
    sudo cp "$INSTALL_DIR/editconf.py" /usr/bin
    sudo chmod +x /usr/bin/editconf.py
    echo "Files copied."
}

# Function to perform preflight checks
preflight_checks() {
    echo "Running preflight checks..."
    source "$INSTALL_DIR/preflight.sh" || {
        log_error "Preflight checks failed. Exiting."
        exit 1
    }
    echo "Preflight checks completed."
}

# Function to handle initial setup or existing configuration
setup_yiimpool() {
    if [ -f "$YIIMPOOL_CONF" ]; then
        # Load existing configuration files
        echo "Loading existing configuration..."
        cat "$YIIMPOOL_CONF" | sed 's/^/DEFAULT_/' >/tmp/yiimpool.prev.conf
        source /tmp/yiimpool.prev.conf
        source "$YIIMPOOL_DONATE_CONF"
        source "$YIIMPOOL_VERSION_CONF"
        rm -f /tmp/yiimpool.prev.conf
    else
        # First-time setup
        echo "Performing first-time setup..."
        FIRST_TIME_SETUP=1
    fi

    if [[ "$FIRST_TIME_SETUP" == "1" ]]; then
        clear
        # Additional setup steps for first-time installation
        echo "Performing first-time installation steps..."
        source "$INSTALL_DIR/existing_user.sh"  
    else
        clear
        # Setup for subsequent runs
        echo "Performing setup for subsequent runs..."
        source "$INSTALL_DIR/create_user.sh"    
    fi
}

# Main script execution starts here

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root."
    exit 1
fi

# Set UTF-8 locale
set_utf8_locale

# Install dependencies
install_dependencies

# Copy necessary files
copy_files

# Perform preflight checks
preflight_checks

# Setup Yiimpoolv2
setup_yiimpool

source "$INSTALL_DIR/menu.sh"