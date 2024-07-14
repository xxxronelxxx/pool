#!/usr/bin/env bash

##################################################################################
# This is the entry point for configuring the system.                            #
#                                                                                #
# Author: Afiniel                                                                #
# Date: 2024-07-13                                                               #
##################################################################################

set -e

# Recall the last settings used if we're running this a second time.
if [ -f /etc/yiimpool.conf ]; then
    # Load the old .conf file to get existing configuration options loaded into variables with a DEFAULT_ prefix.
    sed 's/^/DEFAULT_/' /etc/yiimpool.conf >/tmp/yiimpool.prev.conf
    source /tmp/yiimpool.prev.conf
    source /etc/yiimpooldonate.conf
    source /etc/yiimpoolversion.conf
    rm -f /tmp/yiimpool.prev.conf
else
    FIRST_TIME_SETUP=1
fi

if [[ "$FIRST_TIME_SETUP" == "1" ]]; then
    clear
    cd "$HOME/Yiimpoolv2/install"

    # Copy functions to /etc
    source functions.sh
    sudo cp functions.sh /etc/
    sudo cp editconf.py /usr/bin
    sudo chmod +x /usr/bin/editconf.py

    # Check system setup
    source preflight.sh

    # Ensure Python reads/writes files in UTF-8
    if ! locale -a | grep en_US.utf8; then
        hide_output locale-gen en_US.UTF-8
    fi

    export LANGUAGE=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
    export LC_TYPE=en_US.UTF-8
    export NCURSES_NO_UTF8_ACS=1

    # Install needed packages
    echo -e "${YELLOW} => Installing needed packages for setup to ${GREEN}continue${YELLOW} <= ${COL_RESET}"
    hide_output sudo apt-get -q update
    hide_output sudo apt-get install -y figlet lolcat
    apt_get_quiet install dialog python3 python3-pip acl nano git apt-transport-https || exit 1

    # Are we running as root?
    if [[ $EUID -ne 0 ]]; then
        # Welcome message for non-root user
        message_box "YiimpoolV2 Installer $VERSION" \
        "Welcome to the Yiimpool Installer!
        \n\nThis installer will guide you through the setup of Yiimpool, an open-source cryptocurrency mining pool server.
        \n\nThe installation process is mostly automated and will require minimal input from you. Ensure that you are installing on a fresh Ubuntu 20.04, 18.04, or 16.04 system.
        \n\nNOTE: Root privileges are required for installation. Please re-run the script as root if you encounter any permission issues."
        source existing_user.sh
    else
        source create_user.sh
    fi
    cd ~

else
    clear

    # Ensure Python reads/writes files in UTF-8
    if ! locale -a | grep -q en_US.utf8; then
        hide_output locale-gen en_US.UTF-8
    fi

    export LANGUAGE=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
    export LC_TYPE=en_US.UTF-8
    export NCURSES_NO_UTF8_ACS=1

    # Load functions and configuration
    source /etc/functions.sh
    source /etc/yiimpool.conf

    # Start Yiimpool
    cd "$HOME/Yiimpoolv2/install"
    source menu.sh
    cd ~
fi
