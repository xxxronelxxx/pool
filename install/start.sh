#!/usr/bin/env bash

##################################################################################
# This is the entry point for configuring the system.                            #
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox   #
# Updated by Afiniel for yiimpool use...                                         #
##################################################################################

# Include functions for color output and other utilities (prefer local copy)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/functions.sh" ]; then
    # Temporarily relax nounset during sourcing of external script if set
    set +u
    source "$SCRIPT_DIR/functions.sh"
    set -u
else
    set +u
    source /etc/functions.sh
    set -u
fi

# Define colors if not defined in functions.sh
YELLOW=${YELLOW:-"\033[1;33m"}
GREEN=${GREEN:-"\033[0;32m"}
RED=${RED:-"\033[0;31m"}
NC=${NC:-"\033[0m"} # No Color

# Enable strict mode and trap errors for safer execution
set -euo pipefail
trap 'print_error "error trapped"' ERR

FIRST_TIME_SETUP=0

# Ensure donation config exists early to avoid missing-file errors later
if [ ! -f /etc/yiimpooldonate.conf ]; then
    print_warning "Donation config missing; creating defaults"
    cat > /tmp/yiimpooldonate.conf <<'DONATEEOF'
BTCDON="3ELCjkScgaJbnqQiQvXb7Mwos1Y2x7hBFK"
LTCDON="M8uerJZUgBn9KbTn8ng9MasM9nWFgsGftW"
ETHDON="0xdA929d4f03e1009Fc031210DDE03bC40ea66D044"
BCHDON="qpse55j0kg0txz0zyx8nsrv3pvd039c09ypplsfn87"
DOGEDON="DKBddo8Qoh19PCFtopBkwTpcEU1aAqdM7S"
DONATEEOF
    sudo mv /tmp/yiimpooldonate.conf /etc/yiimpooldonate.conf
fi

# Recall the last settings used if we're running this a second time.
if [ -f /etc/yiimpool.conf ]; then
    echo -e "${YELLOW}Loading previous configuration settings...${NC}\n"
    # Load existing config options into variables with DEFAULT_ prefix,
    # only for valid VAR=... lines (skip blanks/comments), and normalize spacing
    awk -F= '
      /^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*[[:space:]]*=/ {
        name=$1;
        sub(/^[[:space:]]*/, "", name);
        sub(/[[:space:]]*$/, "", name);
        # get value including any = in it
        val=substr($0, index($0, "=")+1);
        print "DEFAULT_" name "=" val;
      }
    ' /etc/yiimpool.conf > /tmp/yiimpool.prev.conf
    set +u
    source /tmp/yiimpool.prev.conf
    set -u
    echo -e "${GREEN}Loaded previous configuration settings.${NC}\n"
    echo -e "${YELLOW}Loading donation settings and version information...${NC}\n"
    if [ -f /etc/yiimpooldonate.conf ]; then
        source /etc/yiimpooldonate.conf
    else
        print_warning "Donation config missing; creating defaults"
        echo 'BTCDON="3ELCjkScgaJbnqQiQvXb7Mwos1Y2x7hBFK"\nLTCDON="M8uerJZUgBn9KbTn8ng9MasM9nWFgsGftW"\nETHDON="0xdA929d4f03e1009Fc031210DDE03bC40ea66D044"\nBCHDON="qpse55j0kg0txz0zyx8nsrv3pvd039c09ypplsfn87"\nDOGEDON="DKBddo8Qoh19PCFtopBkwTpcEU1aAqdM7S"' | sudo -E tee /etc/yiimpooldonate.conf > /dev/null 2>&1
        source /etc/yiimpooldonate.conf
    fi
    source /etc/yiimpoolversion.conf
    echo -e "${GREEN}Loaded donation settings and version information.${NC}\n"
    rm -f /tmp/yiimpool.prev.conf
    echo -e "${GREEN}Removed temporary previous configuration file.${NC}\n"
else
    FIRST_TIME_SETUP=1
    echo -e "${YELLOW}First-time setup detected.${NC}\n"
fi

if [[ "$FIRST_TIME_SETUP" == "1" ]]; then
    clear
    cd "$HOME/Yiimpoolv1/install"

    print_header "First-time setup"
    # Copy functions to /etc
    source functions.sh
    sudo cp -r functions.sh /etc/
    sudo cp -r editconf.py /usr/bin
    sudo chmod +x /usr/bin/editconf.py
    print_success "Copied functions and editconf.py to system directories"

    # Check system setup: Are we running as root on Ubuntu 16.04/18.04/20.04 on a
    # machine with enough memory?
    # If not, this shows an error and exits.
    print_status "Running preflight system checks"
    # Always source preflight from this script's directory to avoid stale copies
    source "$SCRIPT_DIR/preflight.sh"

    # Ensure Python reads/writes files in UTF-8.
    if ! locale -a | grep en_US.utf8 >/dev/null; then
    print_status "Generating en_US.UTF-8 locale"
        hide_output locale-gen en_US.UTF-8
    fi

    export LANGUAGE=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
    export LC_TYPE=en_US.UTF-8
    print_success "System locale set to en_US.UTF-8"

    # Fix so line drawing characters are shown correctly in Putty on Windows. See #744.
    export NCURSES_NO_UTF8_ACS=1
    print_success "Configured NCURSES line drawing"

    # Check for user
    print_status "Installing bootstrap packages"
    hide_output sudo apt-get -q -q update
    hide_output sudo apt-get install -y figlet
    hide_output sudo apt-get install -y lolcat
    apt_get_quiet install dialog python3 python3-pip acl nano git apt-transport-https || exit 1
    print_success "Bootstrap packages installed"

    # Are we running as root?
    if [[ $EUID -ne 0 ]]; then
        print_info "Running as non-root user"
        # Welcome
        message_box "Yiimpool Installer $VERSION" \
        "${YELLOW}Hello and thanks for using the Yiimpool Installer!${NC}
        \n\n${GREEN}Installation for the most part is fully automated. In most cases any user responses that are needed are asked prior to the installation.${NC}
        \n\n${RED}NOTE: You should only install this on a brand new Ubuntu 20.04, Ubuntu 18.04, or Ubuntu 16.04 installation.${NC}"
        source existing_user.sh
        exit
    else
        print_info "Running as root; creating user"
        source create_user.sh
        exit
    fi
    cd ~

else
    clear
    print_header "Subsequent run"

    # Ensure Python reads/writes files in UTF-8.
    if ! locale -a | grep en_US.utf8 >/dev/null; then
        print_status "Generating en_US.UTF-8 locale"
        hide_output locale-gen en_US.UTF-8
    fi

    export LANGUAGE=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
    export LC_TYPE=en_US.UTF-8
    print_success "System locale set to en_US.UTF-8"

    export NCURSES_NO_UTF8_ACS=1
    print_success "Configured NCURSES line drawing"

    print_status "Loading system functions and configuration"
    source /etc/functions.sh
    source /etc/yiimpool.conf
    print_success "Loaded system functions and configuration"

    # Start yiimpool
    print_header "Starting Yiimpool installation"
    cd "$HOME/Yiimpoolv1/install"
    source menu.sh
    cd ~
fi
