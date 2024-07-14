#!/usr/bin/env bash

##################################################################################
# PreSetup script for configuring the system for Yiimpool.                      #
#                                                                              #
# Author: Afiniel                                                              #
# Date: 2024-07-14                                                             #
##################################################################################

# Source necessary functions and configurations
source /etc/functions.sh
clear

echo -e "${YELLOW} => Setting our global variables <= ${NC}"

# Set default values for variables
PUBLIC_IP="auto"
PUBLIC_IPV6="auto"
DEFAULT_PUBLIC_IP=""
DEFAULT_PUBLIC_IPV6=""

# Function to create directory and set ACLs
setup_directory_and_acls() {
    local directory="$1"
    local user="$2"

    # Create directory if it doesn't exist
    if [ ! -d "$directory" ]; then
        sudo mkdir -p "$directory"
    fi

    # Set ACLs if directory exists
    if [ -d "$directory" ]; then
        sudo setfacl -m u:"$user":rwx "$directory"
    else
        echo "Directory $directory does not exist or could not be created."
        # Handle directory creation or ACL setting errors as needed
        return 1
    fi
}

# Set up directories and ACLs as needed
setup_directory_and_acls "/home/root/yiimpoolv2" "$USER"

# If PUBLIC_IP variable is not set, attempt to guess or ask the user
if [ -z "${PUBLIC_IP:-}" ]; then
    GUESSED_IP=$(get_publicip_from_web_service 4)

    if [[ -z "${DEFAULT_PUBLIC_IP:-}" && ! -z "$GUESSED_IP" ]]; then
        PUBLIC_IP=$GUESSED_IP
    elif [ "${DEFAULT_PUBLIC_IP:-}" == "$GUESSED_IP" ]; then
        PUBLIC_IP=$GUESSED_IP
    fi

    if [ -z "${PUBLIC_IP:-}" ]; then
        input_box "Public IP Address" \
        "Enter the public IP address of this machine, as given to you by your ISP.
        \n\nPublic IP address:" \
        "$DEFAULT_PUBLIC_IP" \
        PUBLIC_IP

        if [ -z "$PUBLIC_IP" ]; then
            exit # User canceled
        fi
    fi
fi

# Similar process for IPv6
if [ -z "${PUBLIC_IPV6:-}" ]; then
    GUESSED_IP=$(get_publicip_from_web_service 6)
    MATCHED=0

    if [[ -z "${DEFAULT_PUBLIC_IPV6:-}" && ! -z "$GUESSED_IP" ]]; then
        PUBLIC_IPV6=$GUESSED_IP
    elif [[ "${DEFAULT_PUBLIC_IPV6:-}" == "$GUESSED_IP" ]]; then
        PUBLIC_IPV6=$GUESSED_IP
        MATCHED=1
    elif [[ -z "${DEFAULT_PUBLIC_IPV6:-}" ]]; then
        DEFAULT_PUBLIC_IP=$(get_default_privateip 6)
    fi

    if [[ -z "${PUBLIC_IPV6:-}" && $MATCHED == 0 ]]; then
        input_box "IPv6 Address (Optional)" \
        "Enter the public IPv6 address of this machine, as given to you by your ISP.
        \n\nLeave blank if the machine does not have an IPv6 address.
        \n\nPublic IPv6 address:" \
        ${DEFAULT_PUBLIC_IPV6:-} \
        PUBLIC_IPV6

        if [ ! $PUBLIC_IPV6_EXITCODE ]; then
            exit # User canceled
        fi
    fi
fi

# Automatic configuration, e.g., for Vagrant
if [ "$PUBLIC_IP" = "auto" ]; then
    PUBLIC_IP=$(get_publicip_from_web_service 4 || get_default_privateip 4)
fi

if [ "$PUBLIC_IPV6" = "auto" ]; then
    PUBLIC_IPV6=$(get_publicip_from_web_service 6 || get_default_privateip 6)
fi

# Export variables to configuration file
echo "STORAGE_USER=${STORAGE_USER}" | sudo -E tee /etc/yiimpool.conf >/dev/null 2>&1
echo "STORAGE_ROOT=${STORAGE_ROOT}" | sudo -E tee -a /etc/yiimpool.conf >/dev/null 2>&1
echo "PUBLIC_IP=${PUBLIC_IP}" | sudo -E tee -a /etc/yiimpool.conf >/dev/null 2>&1
echo "PUBLIC_IPV6=${PUBLIC_IPV6}" | sudo -E tee -a /etc/yiimpool.conf >/dev/null 2>&1

exit 0
