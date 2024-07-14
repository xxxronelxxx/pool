#!/usr/bin/env bash

#########################################################
# Functions for Yiimpool Installer Script
#
# Author: Afiniel
# Date: 2024-07-13
#########################################################

# Colors And Spinner.

ESC_SEQ="\x1b["
NC='\033[0m' # No Color
RED=$ESC_SEQ"31;01m"
GREEN=$ESC_SEQ"32;01m"
YELLOW=$ESC_SEQ"33;01m"
BLUE=$ESC_SEQ"34;01m"
MAGENTA=$ESC_SEQ"35;01m"
CYAN=$ESC_SEQ"36;01m"

spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    local start_time=$(date +%s)
    local total_seconds=300  # Example total duration of the process in seconds (adjust as needed)

    while ps -p $pid > /dev/null; do
        local current_time=$(date +%s)
        local elapsed_seconds=$((current_time - start_time))
        
        # Calculate progress percentage
        local progress=$(( (elapsed_seconds * 100) / total_seconds ))
        if [ $progress -gt 100 ]; then
            progress=100
        fi
        
        local remaining_seconds=$(( total_seconds - elapsed_seconds ))
        
        local hours=$((remaining_seconds / 3600))
        local minutes=$(( (remaining_seconds % 3600) / 60 ))
        local seconds=$((remaining_seconds % 60))

        # Print elapsed time and estimated time remaining (ETA)
        printf "\r[Elapsed: %02d:%02d:%02d] [ETA: %02d:%02d:%02d] [%c] %d%%" \
            $((elapsed_seconds / 3600)) $(( (elapsed_seconds % 3600) / 60 )) $((elapsed_seconds % 60)) \
            $hours $minutes $seconds \
            "${spinstr:0:1}" \
            $progress

        # Rotate spinner animation
        spinstr=${spinstr:1}${spinstr:0:1}
        sleep $delay

        # Check if the process has completed
        if ! ps -p $pid > /dev/null; then
            break
        fi
    done

    printf "\r                        \r"  # Clear timer, spinner, and ETA
}

# Function to execute a command and hide its output
hide_output() {
    local OUTPUT=$(mktemp)
    "$@" &>$OUTPUT &
    local pid=$!

    # Run spinner function in the background
    spinner $pid

    local E=$?
    wait $pid  # Wait for the background process to finish
    local exit_status=$?

    if [ $exit_status != 0 ]; then
        echo " "
        echo "FAILED: $@"
        echo "-----------------------------------------"
        cat $OUTPUT
        echo "-----------------------------------------"
        rm -f $OUTPUT
        exit $exit_status
    fi

    rm -f $OUTPUT
}

# Function to run apt-get quietly
apt_get_quiet() {
    DEBIAN_FRONTEND=noninteractive hide_output sudo apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" "$@"
}

# Function to display a message box
message_box() {
    dialog --title "$1" --msgbox "$2" 0 0
}

# Function to display an input box and store user input
input_box() {
    local result
    local result_code
    declare -n result_var="$4"
    declare -n result_code_var="${4}_EXITCODE"
    
    result=$(dialog --stdout --title "$1" --inputbox "$2" 0 0 "$3")
    result_code=$?
    
    # Assign the result to the variable specified by $4
    result_var="$result"
    
    # Store the exit code from dialog in ${4}_EXITCODE
    result_code_var=$result_code
}

# Function to get the public IP from a web service
get_publicip_from_web_service() {
    # Pass '4' or '6' as an argument to specify IPv4 or IPv6
    curl -$1 --fail --silent --max-time 15 icanhazip.com 2>/dev/null
}

# Function to get the default private IP
get_default_privateip() {
    # Pass '4' or '6' as an argument to specify IPv4 or IPv6
    target=8.8.8.8
    
    # For IPv6, use the corresponding IPv6 address of Google Public DNS
    if [ "$1" == "6" ]; then target=2001:4860:4860::8888; fi
    
    # Get the route information
    route=$(ip -$1 -o route get $target | grep -v unreachable)
    
    # Parse the address out of the route information
    address=$(echo $route | sed "s/.* src \([^ ]*\).*/\1/")
    
    if [[ "$1" == "6" && $address == fe80:* ]]; then
        # For IPv6 link-local addresses, parse the interface and append it with a '%'
        interface=$(echo $route | sed "s/.* dev \([^ ]*\).*/\1/")
        address=$address%$interface
    fi
    
    echo $address
}

# Welcome message box
welcome_message() {
    message_box "Yiimpool Installer $VERSION" \
    "Hello and thanks for using the Yiimpool Yiimp Installer!
    \n\nInstallation for the most part is fully automated. In most cases any user responses that are needed are asked prior to the installation.
    \n\nNOTE: You should only install this on a brand new Ubuntu 20.04 , Ubuntu 18.04 or Ubuntu 16.04 installation."
}

# Function to warn about root privileges
root_warning_message() {
    message_box "Yiimpool Installer $VERSION" \
    "WARNING: You are about to run this script as root!
    \n\n The program will create a new user account with sudo privileges. 
    \n\nThe next step, you will be asked to create a new user account, you can name it whatever you want."
}

# Function to setup additional configurations
setup_configuration() {
    # Check required files and set global variables
    cd $HOME/Yiimpoolv2/install
    source pre_setup.sh
    
    # Create STORAGE_USER and STORAGE_ROOT if they don't exist
    if ! id -u $STORAGE_USER >/dev/null 2>&1; then
        sudo useradd -m $STORAGE_USER
    fi
    if [ ! -d $STORAGE_ROOT ]; then
        sudo mkdir -p $STORAGE_ROOT
    fi
    
    # Save global options in /etc/yiimpool.conf
    echo "STORAGE_USER='$STORAGE_USER'" > /etc/yiimpool.conf
    echo "STORAGE_ROOT='$STORAGE_ROOT'" >> /etc/yiimpool.conf
    echo "PUBLIC_IP='$PUBLIC_IP'" >> /etc/yiimpool.conf
    echo "PUBLIC_IPV6='$PUBLIC_IPV6'" >> /etc/yiimpool.conf
    echo "DISTRO='$DISTRO'" >> /etc/yiimpool.conf
    echo "PRIVATE_IP='$PRIVATE_IP'" >> /etc/yiimpool.conf
    
    # Set donor addresses
    echo 'BTCDON="bc1q582gdvyp09038hp9n5sfdtp0plkx5x3yrhq05y"
    LTCDON="ltc1qqw7cv4snx9ctmpcf25x26lphqluly4w6m073qw"
    ETHDON="0x50C7d0BF9714dBEcDc1aa6Ab0E72af8e6Ce3b0aB"
    BCHDON="qzz0aff2k0xnwyzg7k9fcxlndtaj4wa65uxteqe84m"
    DOGEDON="DSzcmyCRi7JeN4XUiV2qYhRQAydNv7A1Yb"' | sudo -E tee /etc/yiimpooldonate.conf >/dev/null 2>&1
    
    # Copy installation script to user's home directory
    sudo cp -r ~/Yiimpoolv2 /home/${yiimpadmin}/
    cd ~
    sudo setfacl -m u:${yiimpadmin}:rwx /home/${yiimpadmin}/Yiimpoolv2
    sudo rm -r $HOME/Yiimpoolv2
    
    clear
    echo -e "${YELLOW}New User: ${MAGENTA}${yiimpadmin} ${GREEN}created! ${NC}"
    echo
    echo -e "${YELLOW}Please ${RED}reboot ${YELLOW}system and log in as the new user: ${MAGENTA}${yiimpadmin} ${YELLOW}and type ${GREEN}yiimpool ${YELLOW}to ${GREEN}continue ${YELLOW}setup. ${NC}"
    exit 0
}

# Function to determine SSH key usage
choose_ssh_or_password() {
    dialog --title "Create New User With SSH Key" \
    --yesno "Do you want to create new user with SSH key login?
    Selecting no will create user with password login only." 7 60
    response=$?
    case $response in
    0) UsingSSH=yes ;;
    1) UsingSSH=no ;;
    255) echo "[ESC] key pressed." ;;
    esac
}

# Function to create user with SSH key
create_user_with_ssh() {
    clear
    
    # Prompt for username if not set
    if [ -z "${yiimpadmin:-}" ]; then
        DEFAULT_yiimpadmin=yiimpadmin
        input_box "New username" \
        "Please enter your new username.
        \n\nUser Name:" \
        ${DEFAULT_yiimpadmin} \
        yiimpadmin
        
        if [ -z "${yiimpadmin}" ]; then
            exit
        fi
    fi
    
    # Prompt for SSH public key if not set
    if [ -z "${ssh_key:-}" ]; then
        DEFAULT_ssh_key=PublicKey
        input_box "Paste SSH Public Key" \
        "Please paste your SSH public key.
        \n\nPublic Key:" \
        ${DEFAULT_ssh_key} \
        ssh_key
        
        if [ -z "${ssh_key}" ]; then
            exit
        fi
    fi
    
    # Generate random password
    RootPassword=$(openssl rand -base64 8 | tr -d "=+/")
    clear
    
    # Add user, set password, and configure SSH key
    echo -e "${YELLOW}=> Adding new user and setting SSH key... <= ${NC}"
    sudo adduser ${yiimpadmin} --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
    echo -e "${RootPassword}\n${RootPassword}" | passwd ${yiimpadmin}
    sudo usermod -aG sudo ${yiimpadmin}
    
    # Create SSH Key structure
    mkdir -p /home/${yiimpadmin}/.ssh
    touch /home/${yiimpadmin}/.ssh/authorized_keys
    chown -R ${yiimpadmin}:${yiimpadmin} /home/${yiimpadmin}/.ssh
    chmod 700 /home/${yiimpadmin}/.ssh
    chmod 644 /home/${yiimpadmin}/.ssh/authorized_keys
    echo "$ssh_key" >"/home/${yiimpadmin}/.ssh/authorized_keys"
    
    # Configure sudoers and yiimpool command
    echo "# yiimp
    # It needs passwordless sudo functionality.
    ${yiimpadmin} ALL=(ALL) NOPASSWD:ALL
    " | sudo -E tee /etc/sudoers.d/${yiimpadmin} >/dev/null 2>&1
    
    echo '
    cd ~/Yiimpoolv2/install
    bash start.sh
    ' | sudo -E tee /usr/bin/yiimpool >/dev/null 2>&1
    sudo chmod +x /usr/bin/yiimpool
    
    # Setup other configurations
    setup_configuration
}

# Function to create user with password login
create_user_with_password() {
    # Prompt for username if not set
    if [ -z "${yiimpadmin:-}" ]; then
        DEFAULT_yiimpadmin=yiimpadmin
        input_box "Create new username" \
        "Please enter your new username.
        \n\nUser Name:" \
        ${DEFAULT_yiimpadmin} \
        yiimpadmin
        
        if [ -z "${yiimpadmin}" ]; then
            exit
        fi
    fi
    
    # Prompt for password if not set
    if [ -z "${RootPassword:-}" ]; then
        DEFAULT_RootPassword=$(openssl rand -base64 8 | tr -d "=+/")
        input_box "User Password" \
        "Enter your new user password or use this randomly generated one.
        \n\nUnfortunately, dialog doesn't allow copying, so write it down.
        \n\nUser password:" \
        ${DEFAULT_RootPassword} \
        RootPassword
        
        if [ -z "${RootPassword}" ]; then
            exit
        fi
    fi
    
    clear
    
    # Verify user input
    dialog --title "Verify Your Input" \
    --yesno "Please verify your answers before you continue:
    New User Name : ${yiimpadmin}
    New User Pass : ${RootPassword}" 8 60
    
    response=$?
    case $response in
    0)
        clear
        echo -e "${YELLOW}=> Adding new user and password... <= ${NC}"
        
        sudo adduser ${yiimpadmin} --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
        echo -e "${RootPassword}\n${RootPassword}" | passwd ${yiimpadmin}
        sudo usermod -aG sudo ${yiimpadmin}
        
        # Configure sudoers and yiimpool command
        echo "# yiimp
        # It needs passwordless sudo functionality.
        ${yiimpadmin} ALL=(ALL) NOPASSWD:ALL
        " | sudo -E tee /etc/sudoers.d/${yiimpadmin} >/dev/null 2>&1
        
        echo '
        cd ~/Yiimpoolv2/install
        bash start.sh
        ' | sudo -E tee /usr/bin/yiimpool >/dev/null 2>&1
        sudo chmod +x /usr/bin/yiimpool
        
        # Setup other configurations
        setup_configuration
        ;;
    1)
        clear
        bash $(basename $0) && exit;;
    esac
}
