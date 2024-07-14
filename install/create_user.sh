#!/bin/env bash

##################################################################################
# This is the entry point for configuring the system.                            #
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox   #
# Updated by Afiniel for yiimpool use...                                         #
##################################################################################

source /etc/yiimpoolversion.conf || { echo "Error: Unable to source /etc/yiimpoolversion.conf"; exit 1; }
source /etc/functions.sh || { echo "Error: Unable to source /etc/functions.sh"; exit 1; }
cd ~/Yiimpoolv2/install || { echo "Error: Unable to change directory to ~/Yiimpoolv2/install"; exit 1; }
clear

# Welcome
message_box "Yiimpool Installer $VERSION" \
"Hello and thanks for using the Yiimpool Yiimp Installer!
\n\nInstallation for the most part is fully automated. In most cases any user responses that are needed are asked prior to the installation.
\n\nNOTE: You should only install this on a brand new Ubuntu 20.04, Ubuntu 18.04, or Ubuntu 16.04 installation."

# Root warning message box
message_box "Yiimpool Installer $VERSION" \
"WARNING: You are about to run this script as root!
\n\nThe program will create a new user account with sudo privileges. 
\n\nThe next step, you will be asked to create a new user account, you can name it whatever you want."

# Ask if SSH key or password user
dialog --title "Create New User With SSH Key" \
--yesno "Do you want to create a new user with SSH key login?
Selecting no will create a user with password login only." 7 60
response=$?
case $response in
    0) UsingSSH=yes ;;
    1) UsingSSH=no ;;
    255) echo "[ESC] key pressed."; exit 1 ;;
esac

# Function to create a new user
create_user() {
    local username=$1
    local password=$2
    local ssh_key=$3
    
    sudo adduser "$username" --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password || { echo "Error: Failed to add user."; exit 1; }
    echo -e "${password}\n${password}" | sudo passwd "$username" || { echo "Error: Failed to set user password."; exit 1; }
    sudo usermod -aG sudo "$username" || { echo "Error: Failed to add user to sudo group."; exit 1; }

    if [ "$UsingSSH" == "yes" ]; then
        mkdir -p /home/"$username"/.ssh || { echo "Error: Failed to create .ssh directory."; exit 1; }
        touch /home/"$username"/.ssh/authorized_keys || { echo "Error: Failed to create authorized_keys file."; exit 1; }
        echo "$ssh_key" > /home/"$username"/.ssh/authorized_keys || { echo "Error: Failed to write SSH key."; exit 1; }
        chown -R "$username":"$username" /home/"$username"/.ssh || { echo "Error: Failed to set ownership."; exit 1; }
        chmod 700 /home/"$username"/.ssh || { echo "Error: Failed to set .ssh directory permissions."; exit 1; }
        chmod 644 /home/"$username"/.ssh/authorized_keys || { echo "Error: Failed to set authorized_keys permissions."; exit 1; }
    fi

    # Enabling yiimpool command
    echo "# yiimp
# It needs passwordless sudo functionality.
\"$username\" ALL=(ALL) NOPASSWD:ALL
" | sudo tee /etc/sudoers.d/"$username" > /dev/null 2>&1 || { echo "Error: Failed to write sudoers file."; exit 1; }

    echo '
cd ~/Yiimpoolv2/install
bash start.sh
' | sudo tee /usr/bin/yiimpool > /dev/null 2>&1 || { echo "Error: Failed to create yiimpool command."; exit 1; }
    sudo chmod +x /usr/bin/yiimpool || { echo "Error: Failed to set executable permission for yiimpool."; exit 1; }
}

# If Using SSH Key Login
if [[ "$UsingSSH" == "yes" ]]; then
    clear
    if [ -z "${yiimpadmin:-}" ]; then
        DEFAULT_yiimpadmin=yiimpadmin
        input_box "New username" \
            "Please enter your new username.
\n\nUser Name:" \
            ${DEFAULT_yiimpadmin} \
            yiimpadmin

        if [ -z "${yiimpadmin}" ]; then
            # user hit ESC/cancel
            exit 1
        fi
    fi

    if [ -z "${ssh_key:-}" ]; then
        DEFAULT_ssh_key=PublicKey
        input_box "Please open PuTTY Key Generator on your local machine and generate a new public key." \
            "To paste your Public key use ctrl shift right click.
\n\nPublic Key:" \
            ${DEFAULT_ssh_key} \
            ssh_key

        if [ -z "${ssh_key}" ]; then
            # user hit ESC/cancel
            exit 1
        fi
    fi

    # Create random user password
    RootPassword=$(openssl rand -base64 8 | tr -d "=+/") || { echo "Error: Failed to generate random password."; exit 1; }
    clear

    echo -e "$YELLOW => Adding new user and setting SSH key... <= $NC"
    create_user "$yiimpadmin" "$RootPassword" "$ssh_key"
    echo -e "$YELLOW New User:$MAGENTA ${yiimpadmin} $GREEN created!$YELLOW Make sure you save your$RED private key!$NC"
    echo
    echo -e "$RED Please reboot system and log in as $GREEN ${yiimpadmin} $RED and type$GREEN yiimpool$RED to$GREEN continue$YELLOW setup...$NC"
    exit 0
fi

# New User Password Login Creation
if [ -z "${yiimpadmin:-}" ]; then
    DEFAULT_yiimpadmin=yiimpadmin
    input_box "Create new username" \
        "Please enter your new username.
\n\nUser Name:" \
        ${DEFAULT_yiimpadmin} \
        yiimpadmin

    if [ -z "${yiimpadmin}" ]; then
        # user hit ESC/cancel
        exit 1
    fi
fi

if [ -z "${RootPassword:-}" ]; then
    DEFAULT_RootPassword=$(openssl rand -base64 8 | tr -d "=+/") || { echo "Error: Failed to generate random password."; exit 1; }
    input_box "User Password" \
        "Enter your new user password or use this randomly system generated one.
\n\nUnfortunately dialog doesn't let you copy. So you have to write it down.
\n\nUser password:" \
        ${DEFAULT_RootPassword} \
        RootPassword

    if [ -z "${RootPassword}" ]; then
        # user hit ESC/cancel
        exit 1
    fi
fi

clear

dialog --title "Verify Your input" \
    --yesno "Please verify your answers before you continue:
New User Name : ${yiimpadmin}
New User Pass : ${RootPassword}" 8 60

response=$?
case $response in
    0)
        clear
        echo -e "$YELLOW => Adding new user and password... <= $NC"
        create_user "$yiimpadmin" "$RootPassword"

        # Check required files and set global variables
        cd "$HOME/Yiimpoolv2/install" || { echo "Error: Unable to change directory to ~/Yiimpoolv2/install"; exit 1; }
        source pre_setup.sh || { echo "Error: Unable to source pre_setup.sh"; exit 1; }

        # Create the STORAGE_USER and STORAGE_ROOT directory if they don't already exist.
        if ! id -u "$STORAGE_USER" > /dev/null 2>&1; then
            sudo useradd -m "$STORAGE_USER" || { echo "Error: Failed to create storage user"; exit 1; }
        fi
        if [ ! -d "$STORAGE_ROOT" ]; then
            sudo mkdir -p "$STORAGE_ROOT" || { echo "Error: Failed to create storage root directory"; exit 1; }
        fi

        # Save the global options in /etc/yiimpool.conf
        echo "STORAGE_USER=${STORAGE_USER}
        STORAGE_ROOT=${STORAGE_ROOT}
        PUBLIC_IP=${PUBLIC_IP}
        PUBLIC_IPV6=${PUBLIC_IPV6}
        DISTRO=${DISTRO}
        PRIVATE_IP=${PRIVATE_IP}" | sudo tee /etc/yiimpool.conf > /dev/null 2>&1 || { echo "Error: Failed to write /etc/yiimpool.conf"; exit 1; }

        # Set Donor Addresses
        echo 'BTCDON="bc1qc4qqz8eu5j7u8pxfrfvv8nmcka7whhm225a3f9"
        LTCDON="ltc1qma2lgr2mgmtu7sn6pzddaeac9d84chjjpatpzm"
        ETHDON="0xdA929d4f03e1009Fc031210DDE03bC40ea66D044"
        BCHDON="qpse55j0kg0txz0zyx8nsrv3pvd039c09ypplsfn87"
        DOGEDON="DFPg3VnH4kTbWiejpwsXvq1sP9qbuwYe6Z"' | sudo tee /etc/yiimpooldonate.conf > /dev/null 2>&1 || { echo "Error: Failed to write /etc/yiimpooldonate.conf"; exit 1; }

        sudo cp -r ~/Yiimpoolv2 /home/${yiimpadmin}/ || { echo "Error: Failed to copy Yiimpoolv2 to new user home"; exit 1; }
        cd ~ || { echo "Error: Unable to change directory to home"; exit 1; }
        sudo setfacl -m u:${yiimpadmin}:rwx /home/${yiimpadmin}/Yiimpoolv2 || { echo "Error: Failed to set ACL for new user"; exit 1; }
        sudo rm -r "$HOME/Yiimpoolv2" || { echo "Error: Failed to remove ~/Yiimpoolv2"; exit 1; }
        
        clear
        echo
        echo -e "${YELLOW}Detected the following information:$NC"
        echo
        echo -e "${MAGENTA}USERNAME: ${GREEN}${yiimpadmin}$NC"
        echo -e "${MAGENTA}STORAGE_USER: ${GREEN}${STORAGE_USER}$NC"
        echo -e "${MAGENTA}STORAGE_ROOT: ${GREEN}${STORAGE_ROOT}$NC"
        echo -e "${MAGENTA}PUBLIC_IP: ${GREEN}${PUBLIC_IP}$NC"
        echo -e "${MAGENTA}PUBLIC_IPV6: ${GREEN}${PUBLIC_IPV6}$NC"
        echo -e "${MAGENTA}DISTRO: ${GREEN}${DISTRO}$NC"
        echo -e "${MAGENTA}FIRST_TIME_SETUP: ${GREEN}${FIRST_TIME_SETUP}$NC"
        echo -e "${MAGENTA}PRIVATE_IP: ${GREEN}${PRIVATE_IP}$NC"
        echo -e "$YELLOW New User:$MAGENTA ${yiimpadmin} $GREEN created!$YELLOW Make sure to save your$RED private key!$NC"
        echo
        echo -e "$YELLOW New User:$MAGENTA ${yiimpadmin} $GREEN created$RED $NC"
        echo
        echo -e "$RED Please reboot the system and log in as$GREEN ${yiimpadmin} $RED and type$GREEN yiimpool$RED to$GREEN continue$YELLOW setup...$NC"
        exit 0
        ;;
    1)
        clear
        bash "$(basename "$0")" && exit
        ;;
    255) exit 1 ;;
esac
