#!/bin/env bash

##################################################################################
# This script is the entry point for configuring the Yiimpool system.            #
# Source: https://mailinabox.email/ and https://github.com/mail-in-a-box/mailinabox #
# Updated by Afiniel on 2024-07-14                                               #
##################################################################################

# Sourcing necessary configuration files and functions
source /etc/yiimpoolversion.conf
source /etc/functions.sh
cd ~/Yiimpoolv2/install || { echo "Failed to change directory to ~/Yiimpoolv2/install"; exit 1; }
clear

# Welcome message
message_box "Yiimpool Installer $VERSION" \
"Hello and thank you for using the Yiimpool Installer!
\n\nThe installation is mostly automated. User interaction is required only before installation begins.
\n\nNOTE: This script should be run on a fresh installation of Ubuntu 20.04, Ubuntu 18.04, or Ubuntu 16.04."

# Root warning message box
message_box "Yiimpool Installer $VERSION" \
"WARNING: Running this script as root!
\n\nThe script will create a new user with sudo privileges.
\n\nNext, you will be prompted to create a new user account. You can choose any name you prefer."

# Ask user preference for SSH key or password login
dialog --title "Create New User With SSH Key" \
--yesno "Do you want to create a new user with SSH key login?
Select 'No' to create a user with password login only." 7 60
response=$?
case $response in
0) UsingSSH=yes ;;
1) UsingSSH=no ;;
255) echo "[ESC] key pressed." && exit 1 ;;
esac

# Handling SSH Key login scenario
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
            # User hit ESC/cancel
            exit 1
        fi
    fi

    if [ -z "${ssh_key:-}" ]; then
        DEFAULT_ssh_key=PublicKey
        input_box "Paste your Public Key" \
            "Please open PuTTY Key Generator on your local machine and generate a new public key.
      \n\nTo paste your Public key use ctrl shift right click.
      \n\nPublic Key:" \
            ${DEFAULT_ssh_key} \
            ssh_key

        if [ -z "${ssh_key}" ]; then
            # User hit ESC/cancel
            exit 1
        fi
    fi

    # Generate random user password
    RootPassword=$(openssl rand -base64 8 | tr -d "=+/")
    clear

    # Adding user with SSH key setup
    echo -e "$YELLOW => Adding new user and setting SSH key... <= $NC"
    sudo adduser ${yiimpadmin} --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password || { echo "Failed to add user ${yiimpadmin}"; exit 1; }
    echo -e "${RootPassword}\n${RootPassword}" | sudo passwd ${yiimpadmin} || { echo "Failed to set password for ${yiimpadmin}"; exit 1; }
    sudo usermod -aG sudo ${yiimpadmin} || { echo "Failed to add ${yiimpadmin} to sudo group"; exit 1; }
    
    # Setting up SSH key
    sudo mkdir -p /home/${yiimpadmin}/.ssh || { echo "Failed to create .ssh directory"; exit 1; }
    sudo touch /home/${yiimpadmin}/.ssh/authorized_keys || { echo "Failed to create authorized_keys file"; exit 1; }
    sudo chown -R ${yiimpadmin}:${yiimpadmin} /home/${yiimpadmin}/.ssh || { echo "Failed to change ownership of .ssh directory"; exit 1; }
    sudo chmod 700 /home/${yiimpadmin}/.ssh || { echo "Failed to set permissions on .ssh directory"; exit 1; }
    sudo chmod 644 /home/${yiimpadmin}/.ssh/authorized_keys || { echo "Failed to set permissions on authorized_keys file"; exit 1; }
    authkeys=/home/${yiimpadmin}/.ssh/authorized_keys
    echo "$ssh_key" | sudo tee "$authkeys" >/dev/null || { echo "Failed to write SSH key to authorized_keys"; exit 1; }

    # Enabling yiimpool command
    echo '# yiimp
  # Requires passwordless sudo functionality.
  '"${yiimpadmin}"' ALL=(ALL) NOPASSWD:ALL
  ' | sudo tee /etc/sudoers.d/${yiimpadmin} >/dev/null || { echo "Failed to add sudoers entry"; exit 1; }

    echo '
  cd ~/Yiimpoolv2/install
  bash start.sh
  ' | sudo tee /usr/bin/yiimpool >/dev/null || { echo "Failed to create yiimpool command"; exit 1; }
    sudo chmod +x /usr/bin/yiimpool || { echo "Failed to set execute permission on yiimpool command"; exit 1; }

    # Checking required files and setting global variables
    cd "$HOME/Yiimpoolv2/install" || { echo "Failed to change directory to $HOME/Yiimpoolv2/install"; exit 1; }
    source pre_setup.sh || { echo "Failed to source pre_setup.sh"; exit 1; }

    # Creating STORAGE_USER and STORAGE_ROOT directories if they don't exist
    if ! id -u "$STORAGE_USER" >/dev/null 2>&1; then
        sudo useradd -m "$STORAGE_USER" || { echo "Failed to create storage user $STORAGE_USER"; exit 1; }
    fi
    if [ ! -d "$STORAGE_ROOT" ]; then
        sudo mkdir -p "$STORAGE_ROOT" || { echo "Failed to create storage root directory $STORAGE_ROOT"; exit 1; }
    fi

    # Saving global options in /etc/yiimpool.conf
    echo 'STORAGE_USER='"${STORAGE_USER}"'
    STORAGE_ROOT='"${STORAGE_ROOT}"'
    PUBLIC_IP='"${PUBLIC_IP}"'
    PUBLIC_IPV6='"${PUBLIC_IPV6}"'
    DISTRO='"${DISTRO}"'
    PRIVATE_IP='"${PRIVATE_IP}"'' | sudo tee /etc/yiimpool.conf >/dev/null || { echo "Failed to create /etc/yiimpool.conf"; exit 1; }

    # Setting Donor Addresses
    echo 'BTCDON="bc1qc4qqz8eu5j7u8pxfrfvv8nmcka7whhm225a3f9"
    LTCDON="ltc1qma2lgr2mgmtu7sn6pzddaeac9d84chjjpatpzm"
    ETHDON="0xdA929d4f03e1009Fc031210DDE03bC40ea66D044"
    BCHDON="qpse55j0kg0txz0zyx8nsrv3pvd039c09ypplsfn87"
    DOGEDON="DFPg3VnH4kTbWiejpwsXvq1sP9qbuwYe6Z"' | sudo tee /etc/yiimpooldonate.conf >/dev/null || { echo "Failed to create /etc/yiimpooldonate.conf"; exit 1; }

    # Copying Yiimpoolv2 to user's home directory and setting permissions
    sudo cp -r ~/Yiimpoolv2 /home/${yiimpadmin}/ || { echo "Failed to copy Yiimpoolv2 to /home/${yiimpadmin}/"; exit 1; }
    cd ~ || { echo "Failed to change directory to home"; exit 1; }
    sudo setfacl -m u:${yiimpadmin}:rwx /home/${yiimpadmin}/Yiimpoolv2 || { echo "Failed to set ACL for ${yiimpadmin}"; exit 1; }
    sudo rm -r "$HOME/yiimpool" || { echo "Failed to remove $HOME/yiimpool"; exit 1; }
    clear
    echo -e "$YELLOW New User:$MAGENTA ${yiimpadmin} $GREEN created!$YELLOW Make sure to save your$RED private key!$NC"
    echo
    echo -e "$RED Please reboot the system and log in as$GREEN ${yiimpadmin} $RED and type$GREEN yiimpool$RED to$GREEN continue$YELLOW setup...$NC"
    exit 0
fi

# Creating new user with password login
if [ -z "${yiimpadmin:-}" ]; then
    DEFAULT_yiimpadmin=yiimpadmin
    input_box "Create new username" \
        "Please enter your new username.
  \n\nUser Name:" \
        ${DEFAULT_yiimpadmin} \
        yiimpadmin

    if [ -z "${yiimpadmin}" ]; then
        # User hit ESC/cancel
        exit 1
    fi
fi

# Setting up user password
if [ -z "${RootPassword:-}" ]; then
    DEFAULT_RootPassword=$(openssl rand -base64 8 | tr -d "=+/")
    input_box "User Password" \
        "Enter your new user password or use this randomly generated one.
  \n\nUnfortunately dialog doesn't allow copying. Please write it down.
  \n\nUser password:" \
        ${DEFAULT_RootPassword} \
        RootPassword

    if [ -z "${RootPassword}" ]; then
        # User hit ESC/cancel
        exit 1
    fi
fi

clear

# Verifying user inputs before proceeding
dialog --title "Verify Your input" \
    --yesno "Please verify your answers before you continue:
New User Name : ${yiimpadmin}
New User Pass : ${RootPassword}" 8 60

response=$?
case $response in
0)
    clear
    echo -e "$YELLOW => Adding new user and password... <= $NC"

    # Adding user with password setup
    sudo adduser ${yiimpadmin} --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password || { echo "Failed to add user ${yiimpadmin}"; exit 1; }
    echo -e ""${RootPassword}"\n"${RootPassword}"" | sudo passwd ${yiimpadmin} || { echo "Failed to set password for ${yiimpadmin}"; exit 1; }
    sudo usermod -aG sudo ${yiimpadmin} || { echo "Failed to add ${yiimpadmin} to sudo group"; exit 1; }

    # Enabling yiimpool command
    echo '# yiimp
    # Requires passwordless sudo functionality.
    '"${yiimpadmin}"' ALL=(ALL) NOPASSWD:ALL
    ' | sudo tee /etc/sudoers.d/${yiimpadmin} >/dev/null || { echo "Failed to add sudoers entry"; exit 1; }

    echo '
    cd ~/Yiimpoolv2/install
    bash start.sh
    ' | sudo tee /usr/bin/yiimpool >/dev/null || { echo "Failed to create yiimpool command"; exit 1; }
    sudo chmod +x /usr/bin/yiimpool || { echo "Failed to set execute permission on yiimpool command"; exit 1; }

    # Checking required files and setting global variables
    cd "$HOME/Yiimpoolv2/install" || { echo "Failed to change directory to $HOME/Yiimpoolv2/install"; exit 1; }
    source pre_setup.sh || { echo "Failed to source pre_setup.sh"; exit 1; }

    # Creating STORAGE_USER and STORAGE_ROOT directories if they don't exist
    if ! id -u "$STORAGE_USER" >/dev/null 2>&1; then
        sudo useradd -m "$STORAGE_USER" || { echo "Failed to create storage user $STORAGE_USER"; exit 1; }
    fi
    if [ ! -d "$STORAGE_ROOT" ]; then
        sudo mkdir -p "$STORAGE_ROOT" || { echo "Failed to create storage root directory $STORAGE_ROOT"; exit 1; }
    fi

    # Saving global options in /etc/yiimpool.conf
    echo 'STORAGE_USER='"${STORAGE_USER}"'
    STORAGE_ROOT='"${STORAGE_ROOT}"'
    PUBLIC_IP='"${PUBLIC_IP}"'
    PUBLIC_IPV6='"${PUBLIC_IPV6}"'
    DISTRO='"${DISTRO}"'
    PRIVATE_IP='"${PRIVATE_IP}"'' | sudo tee /etc/yiimpool.conf >/dev/null || { echo "Failed to create /etc/yiimpool.conf"; exit 1; }

    # Setting Donor Addresses
    echo 'BTCDON="bc1qc4qqz8eu5j7u8pxfrfvv8nmcka7whhm225a3f9"
    LTCDON="ltc1qma2lgr2mgmtu7sn6pzddaeac9d84chjjpatpzm"
    ETHDON="0xdA929d4f03e1009Fc031210DDE03bC40ea66D044"
    BCHDON="qpse55j0kg0txz0zyx8nsrv3pvd039c09ypplsfn87"
    DOGEDON="DFPg3VnH4kTbWiejpwsXvq1sP9qbuwYe6Z"' | sudo tee /etc/yiimpooldonate.conf >/dev/null || { echo "Failed to create /etc/yiimpooldonate.conf"; exit 1; }

    # Copying Yiimpoolv2 to user's home directory and setting permissions
    sudo cp -r ~/Yiimpoolv2 /home/${yiimpadmin}/ || { echo "Failed to copy Yiimpoolv2 to /home/${yiimpadmin}/"; exit 1; }
    cd ~ || { echo "Failed to change directory to home"; exit 1; }
    sudo setfacl -m u:${yiimpadmin}:rwx /home/${yiimpadmin}/Yiimpoolv2 || { echo "Failed to set ACL for ${yiimpadmin}"; exit 1; }
    sudo rm -r "$HOME/Yiimpoolv2" || { echo "Failed to remove $HOME/Yiimpoolv2"; exit 1; }
    clear
    echo -e "$YELLOW New User:$MAGENTA ${yiimpadmin} $GREEN created$RED $NC"
    echo
    echo -e "$YELLOW Please$RED reboot$YELLOW system and log in as the new user:$MAGENTA ${yiimpadmin} $YELLOW and type$GREEN yiimpool$YELLOW to$GREEN continue$YELLOW setup.$NC"
    exit 0
    ;;

1)
    # If 'No' is selected, restart the script
    clear
    bash "$(basename "$0")" && exit
    ;;

255) ;;

esac
