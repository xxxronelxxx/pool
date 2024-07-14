#!/usr/bin/env bash

##################################################################################
# PreSetup script for configuring the system for Yiimpool.                       #
#                                                                                #
# Author: Afiniel                                                                #
# Date: 2024-07-14                                                               #
##################################################################################

# Source helper functions
source /etc/functions.sh || { echo "${YELLOW}Failed to source /etc/functions.sh${NC}"; exit 1; }

clear

echo -e "${YELLOW}=> Setting our global variables <=${NC}"

# Set PUBLIC_IP if not already set
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

# Set PUBLIC_IPV6 if not already set
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
