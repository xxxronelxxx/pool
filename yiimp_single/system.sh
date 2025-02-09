#!/bin/env bash

##################################################################################
# This is the entry point for configuring the system.
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by Afiniel for yiimpool use...
##################################################################################

clear
source /etc/functions.sh
source /etc/yiimpool.conf
source $STORAGE_ROOT/yiimp/.yiimp.conf

set -eu -o pipefail

function print_error {
    read line file <<<$(caller)
    echo "An error occurred in line $line of file $file:" >&2
    sed "${line}q;d" "$file" >&2
}
trap print_error ERR

term_art
echo
echo -e "$YELLOW System Configuration Started!${NC}"
echo

# Set timezone to UTC
echo
echo -e "$YELLOW =>  Setting TimeZone to:$GREEN UTC <= ${NC}"
if [ ! -f /etc/timezone ]; then
    echo "Setting timezone to UTC."
    sudo bash -c 'echo "Etc/UTC" > /etc/timezone'
    restart_service rsyslog
fi
echo

hide_output sudo apt-get install -y software-properties-common build-essential

# CertBot
echo

if [[ "$DISTRO" == "16" || "$DISTRO" == "18" ]]; then
    echo -e "$MAGENTA => Installing CertBot PPA <= ${NC}"
    hide_output sudo add-apt-repository -y ppa:certbot/certbot
    hide_output sudo apt-get update
    echo -e "$GREEN => Complete${NC}"
elif [[ "$DISTRO" == "20" || "$DISTRO" == "22" || "$DISTRO" == "23" || "$DISTRO" == "24" ]]; then
    echo -e "$MAGENTA => Installing CertBot PPA <= ${NC}"
    hide_output sudo apt install -y snapd
    hide_output sudo snap install core
    hide_output sudo snap refresh core
    hide_output sudo snap install --classic certbot
    sudo ln -s /snap/bin/certbot /usr/bin/certbot
    echo -e "$GREEN => Complete${NC}"

elif [[ "$DISTRO" == "12" ]]; then
    echo -e "$MAGENTA => Installing CertBot PPA <= ${NC}"
    hide_output sudo apt install -y certbot
    echo -e "$GREEN => Complete${NC}"
fi

echo
echo -e "$MAGENTA Installing MariaDB..${NC}"

# Create directory for keys if it doesn't exist
if [ ! -d /etc/apt/keyrings ]; then
    sudo mkdir -p /etc/apt/keyrings
fi

# Download and add the MariaDB signing key
if [ ! -f /etc/apt/keyrings/mariadb.gpg ]; then
    sudo curl -fsSL https://mariadb.org/mariadb_release_signing_key.pgp | sudo gpg --dearmor -o /etc/apt/keyrings/mariadb.gpg
fi

case "$DISTRO" in
    "16")  # Ubuntu 16.04
        echo "deb [signed-by=/etc/apt/keyrings/mariadb.gpg arch=amd64,arm64,i386,ppc64el] https://mirror.mariadb.org/repo/10.4/ubuntu xenial main" \ 
        ;;
    "18")  # Ubuntu 18.04
        echo "deb [signed-by=/etc/apt/keyrings/mariadb.gpg arch=amd64,arm64,ppc64el] https://mirror.mariadb.org/repo/10.6/ubuntu bionic main" \ 
        ;;
    "20")  # Ubuntu 20.04
        echo "deb [signed-by=/etc/apt/keyrings/mariadb.gpg arch=amd64,arm64,ppc64el,s390x] https://mirror.mariadb.org/repo/10.6/ubuntu focal main" \
        ;;
    "22")  # Ubuntu 22.04
        echo "deb [signed-by=/etc/apt/keyrings/mariadb.gpg arch=amd64,arm64,ppc64el,s390x] https://mirror.mariadb.org/repo/10.6/ubuntu jammy main" \
        ;;
    "23")  # Ubuntu 23.04
        echo "deb [signed-by=/etc/apt/keyrings/mariadb.gpg arch=amd64,arm64,ppc64el,s390x] https://mirror.mariadb.org/repo/11.6/ubuntu lunar main" \
        ;;
    "24")  # Ubuntu 24.04
        echo "deb [signed-by=/etc/apt/keyrings/mariadb.gpg arch=amd64,arm64,ppc64el,s390x] https://mirror.mariadb.org/repo/11.6/ubuntu noble main" \
        ;;
    "12")  # Debian 12
        echo "deb [signed-by=/etc/apt/keyrings/mariadb.gpg arch=amd64,arm64,ppc64el,s390x] https://mirror.mariadb.org/repo/11.6/debian bookworm main" \
        ;;
    "11")  # Debian 11
        echo "deb [signed-by=/etc/apt/keyrings/mariadb.gpg arch=amd64,arm64,ppc64el,s390x] https://mirror.mariadb.org/repo/10.6/debian bullseye main" \
        ;;
    *)
        echo "Unsupported Ubuntu version: $DISTRO"
        exit 1
        ;;
esac
echo -e "$GREEN Complete...${NC}"
hide_output sudo apt-get update

if [ ! -f /boot/grub/menu.lst ]; then
    apt_get_quiet upgrade
else
    sudo rm /boot/grub/menu.lst
    sudo update-grub-legacy-ec2 -y
    apt_get_quiet upgrade
fi

apt_get_quiet dist-upgrade
apt_get_quiet autoremove

echo
echo -e "$MAGENTA => Installing Base system packages <= ${NC}"
hide_output sudo apt-get install -y python3 python3-dev python3-pip
hide_output sudo apt-get install -y wget curl git sudo coreutils bc haveged pollinate unzip unattended-upgrades 
hide_output sudo apt-get install -y cron ntp fail2ban screen rsyslog lolcat nginx haproxy supervisor

echo -e "$GREEN => Complete${NC}"
echo
echo -e "$YELLOW => Initializing system random number generator <= ${NC}"
hide_output dd if=/dev/random of=/dev/urandom bs=1 count=32 2>/dev/null
hide_output sudo pollinate -q -r
echo -e "$GREEN => Complete${NC}"

echo
echo -e "$YELLOW => Initializing UFW Firewall <= ${NC}"
set +eu +o pipefail
if [ -z "${DISABLE_FIREWALL:-}" ]; then
    hide_output sudo apt-get install -y ufw
    echo
    echo -e "$YELLOW => Allow incoming connections to SSH <= ${NC}"
    echo
    ufw_allow ssh
    sleep 0.5
    echo -e "$YELLOW ssh port:$GREEN OPEN ${NC}"
    echo
    sleep 0.5
    ufw_allow http
    echo -e "$YELLOW http port:$GREEN OPEN ${NC}"
    echo
    sleep 0.5
    ufw_allow https
    echo -e "$YELLOW https port:$GREEN OPEN ${NC}"
    echo

    SSH_PORT=$(sshd -T 2>/dev/null | grep "^port " | sed "s/port //")
    if [ ! -z "$SSH_PORT" ] && [ "$SSH_PORT" != "22" ]; then
        echo -e "$YELLOW => Allow incoming connections to SSH <= ${NC}"
        echo
        echo -e "$YELLOW Opening alternate SSH port:$GREEN $SSH_PORT ${NC}"
        echo
        ufw_allow $SSH_PORT
        sleep 0.5
        echo
        echo -e "$YELLOW http port:$GREEN OPEN ${NC}"
        ufw_allow http
        sleep 0.5
        echo
        echo -e "$YELLOW https port:$GREEN OPEN ${NC}"
        ufw_allow https
        sleep 0.5
        echo
    fi

    hide_output sudo ufw --force enable
fi
set -eu -o pipefail
echo
echo -e "$MAGENTA => Installing YiiMP Required system packages <= ${NC}"
if [ -f /usr/sbin/apache2 ]; then
    echo Removing apache...
    hide_output sudo apt-get -y purge apache2 apache2-*
    hide_output sudo apt-get -y --purge autoremove
fi

hide_output sudo apt-get update

echo
echo -e "$CYAN => Installing PHP <= ${NC}"
sleep 3

if [[ "$DISTRO" == "12" || "$DISTRO" == "11" ]]; then
    apt_install python3-launchpadlib
fi

# if Ubuntu 16 18 20 22 24 

if [[ "$DISTRO" == "16" || "$DISTRO" == "18" || "$DISTRO" == "20" || "$DISTRO" == "22" || "$DISTRO" == "24" ]]; then
    if [ ! -f /etc/apt/sources.list.d/ondrej-php-bionic.list ]; then
        hide_output sudo add-apt-repository -y ppa:ondrej/php
    fi
fi 

if [[ "$DISTRO" == "12" || "$DISTRO" == "11" ]]; then
    if [ ! -f /etc/apt/sources.list.d/ondrej-php.list ]; then
        hide_output sudo apt-get install -y apt-transport-https lsb-release ca-certificates
        wget -qO - https://packages.sury.org/php/apt.gpg | sudo apt-key add -
        echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
        hide_output sudo apt-get update
    fi
fi

hide_output sudo apt-get update

# Common PHP packages for all distros
hide_output sudo apt-get install -y php8.1-fpm php8.1-opcache php8.1 php8.1-common php8.1-gd
hide_output sudo apt-get install -y php8.1-mysql php8.1-imap php8.1-cli php8.1-cgi php8.1-curl php8.1-intl php8.1-pspell 
hide_output sudo apt-get install -y php8.1-sqlite3 php8.1-tidy php8.1-xmlrpc php8.1-xsl php8.1-zip php8.1-mbstring 
hide_output sudo apt-get install -y php8.1-memcache php8.1-memcached memcached certbot libssh-dev libbrotli-dev 
hide_output sudo apt-get install -y php-pear php-auth-sasl mcrypt imagemagick libruby php-imagick php-gettext 
hide_output sudo apt-get install -y fail2ban ntpdate python3 python3-dev python3-pip curl git sudo coreutils 
hide_output sudo apt-get install -y pollinate unzip unattended-upgrades cron pwgen libgmp3-dev libmysqlclient-dev 
hide_output sudo apt-get install -y libcurl4-gnutls-dev libkrb5-dev libldap2-dev libidn11-dev gnutls-dev librtmp-dev 
hide_output sudo apt-get install -y build-essential libtool autotools-dev automake pkg-config libevent-dev bsdmainutils 
hide_output sudo apt-get install -y libssl-dev automake cmake gnupg2 ca-certificates lsb-release nginx certbot libsodium-dev 
hide_output sudo apt-get install -y libnghttp2-dev librtmp-dev libssh2-1 libssh2-1-dev libldap2-dev libidn11-dev libpsl-dev libkrb5-dev

sleep 2

# Check if php8.1-fpm service exists before trying to start it
if systemctl list-unit-files | grep -q php8.1-fpm.service; then
    sudo systemctl start php8.1-fpm
    sudo systemctl status php8.1-fpm | sed -n "1,3p"
else
    echo "php8.1-fpm service not found. Please check PHP installation."
fi
echo -e "$GREEN => Complete${NC}"

#phpMyAdmin
echo -e "$CYAN => Installing phpMyAdmin <= ${NC}"

hide_output sudo wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
hide_output sudo tar xzf phpMyAdmin-latest-all-languages.tar.gz
hide_output sudo rm phpMyAdmin-latest-all-languages.tar.gz
hide_output sudo mv phpMyAdmin-*-all-languages /usr/share/phpmyadmin
hide_output sudo mkdir -p /usr/share/phpmyadmin/tmp
hide_output sudo chmod 777 /usr/share/phpmyadmin/tmp
echo -e "$GREEN => Complete${NC}"

echo
echo -e "$CYAN => Setting PHP to 8.1 ${NC}"
sudo update-alternatives --set php /usr/bin/php8.1
echo -e "$GREEN => Complete${NC}"

echo
echo -e "$CYAN => Cloning Yiimp Repo <= ${NC}"
hide_output sudo git clone ${YiiMPRepo} $STORAGE_ROOT/yiimp/yiimp_setup/yiimp

hide_output sudo service nginx restart
sleep 0.5

set +eu +o pipefail
cd $HOME/Yiimpoolv1/yiimp_single
