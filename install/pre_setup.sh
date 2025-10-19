#!/bin/env bash

##################################################################################
# This is the entry point for configuring the system.                            #
# Source https://mailinabox.email/   https://github.com/mail-in-a-box/mailinabox #
# Updated by Afiniel for yiimpool use...                                         #
##################################################################################

source /etc/functions.sh
clear
echo -e "$YELLOW => Setting our global variables <= ${NC}"

# If the machine is behind a NAT, inside a VM, etc., it may not know
# its IP address on the public network / the Internet. Ask the Internet
# and possibly confirm with user.
if [ -z "${PUBLIC_IP:-}" ]; then
	# Ask the Internet using IPv4 (safe and working).
	GUESSED_IP=$(get_publicip_from_web_service 4)

	# On the first run, if we got an answer from the Internet then don't
	# ask the user.
	if [[ -z "${DEFAULT_PUBLIC_IP:-}" && ! -z "$GUESSED_IP" ]]; then
		PUBLIC_IP=$GUESSED_IP

	# On later runs, if the previous value matches the guessed value then
	# don't ask the user either.
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
			# user hit ESC/cancel
			exit
		fi
	fi
fi

# Same for IPv6. But it's optional. Also, if it looks like the system
# doesn't have an IPv6, don't ask for one.
if [ -z "${PUBLIC_IPV6:-}" ]; then
	# Safely attempt to detect public IPv6 without crashing the script.
	GUESSED_IP=""
	if command -v curl >/dev/null 2>&1; then
		GUESSED_IP=$(curl -6 --max-time 8 -s https://ipv6.icanhazip.com 2>/dev/null)
	elif command -v wget >/dev/null 2>&1; then
		GUESSED_IP=$(wget -6 -qO- --timeout=8 https://ipv6.icanhazip.com 2>/dev/null)
	fi

	MATCHED=0
	if [[ -z "${DEFAULT_PUBLIC_IPV6:-}" && -n "$GUESSED_IP" ]]; then
		PUBLIC_IPV6=$GUESSED_IP
	elif [[ -n "${DEFAULT_PUBLIC_IPV6:-}" && "${DEFAULT_PUBLIC_IPV6}" == "$GUESSED_IP" ]]; then
		PUBLIC_IPV6=$GUESSED_IP
		MATCHED=1
	fi

	# Only prompt if auto-detection failed AND user hasn't set it before
	if [[ -z "${PUBLIC_IPV6:-}" && $MATCHED -eq 0 ]]; then
		# Check if system actually has IPv6 connectivity
		if [[ -f /proc/net/if_inet6 ]] && ip -6 addr show scope global 2>/dev/null | grep -q 'inet6'; then
			input_box "IPv6 Address (Optional)" \
				"Enter the public IPv6 address of this machine, as given to you by your ISP.
				\n\nLeave blank if the machine does not have an IPv6 address.
				\n\nPublic IPv6 address:" \
				"${DEFAULT_PUBLIC_IPV6:-}" \
				PUBLIC_IPV6

			if [ ! $PUBLIC_IPV6_EXITCODE ]; then
				# user hit ESC/cancel
				exit
			fi
		else
			# No IPv6 capability — skip silently
			PUBLIC_IPV6=""
		fi
	fi
fi

# Automatic configuration, e.g. as used in our Vagrant configuration.
if [ "${PUBLIC_IP:-}" = "auto" ]; then
	# Use a public API to get our public IP address, or fall back to local network configuration.
	PUBLIC_IP=$(get_publicip_from_web_service 4 || get_default_privateip 4)
fi
if [ "${PUBLIC_IPV6:-}" = "auto" ]; then
	# Use a public API to get our public IPv6 address, or fall back to local network configuration.
	# But only if IPv6 is actually available.
	if [[ -f /proc/net/if_inet6 ]] && ip -6 route show table all 2>/dev/null | grep -q 'default'; then
		PUBLIC_IPV6=$(curl -6 --max-time 8 -s https://ipv6.icanhazip.com 2>/dev/null || get_default_privateip 6)
	else
		PUBLIC_IPV6=""
	fi
fi
