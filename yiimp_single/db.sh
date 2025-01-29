#!/usr/bin/env bash

#####################################################
# Created by Afiniel for Yiimpool use
#
# This script installs and configures MariaDB for a 
# YiiMP pool setup, including creating DB users and 
# importing default database values.
#
# Author: Afiniel
# Date: 2024-07-15
#####################################################

# Load configuration files
source /etc/functions.sh
source /etc/yiimpoolversion.conf
source /etc/yiimpool.conf
source "$STORAGE_ROOT/yiimp/.yiimp.conf"
source "$HOME/Yiimpoolv1/yiimp_single/.wireguard.install.cnf"

# Set error handling and log errors
set -eu -o pipefail

function print_error {
    read -r line file <<<$(caller)
    echo "An error occurred in line $line of file $file:" >&2
    sed "${line}q;d" "$file" >&2
}
trap print_error ERR

# Display banner
term_art

echo
# Load WireGuard configuration if enabled
if [[ ("$wireguard" == "true") ]]; then
    source "$STORAGE_ROOT/yiimp/.wireguard.conf"
fi

# Define MariaDB version
MARIADB_VERSION='10.4'

echo
echo -e "$MAGENTA     <--$YELLOW Installing MariaDB$MAGENTA $MARIADB_VERSION -->${NC}"
echo 

# Set MariaDB root password for installation
sudo debconf-set-selections <<< "maria-db-$MARIADB_VERSION mysql-server/root_password password $DBRootPassword"
sudo debconf-set-selections <<< "maria-db-$MARIADB_VERSION mysql-server/root_password_again password $DBRootPassword"

# Install MariaDB
apt_install mariadb-server mariadb-client

# Display completion message
echo -e "$GREEN => MariaDB build complete <= ${NC}"
echo

# Display message for creating DB users
echo -e "$MAGENTA => Creating DB users for YiiMP <= ${NC}"
echo

# Define SQL statements based on WireGuard setting
if [[ "$wireguard" == "false" ]]; then
    DB_HOST="localhost"
else
    DB_HOST="$DBInternalIP"
fi

Q1="CREATE DATABASE IF NOT EXISTS ${YiiMPDBName};"
Q2="GRANT ALL ON ${YiiMPDBName}.* TO '${YiiMPPanelName}'@'${DB_HOST}' IDENTIFIED BY '$PanelUserDBPassword';"
Q3="GRANT ALL ON ${YiiMPDBName}.* TO '${StratumDBUser}'@'${DB_HOST}' IDENTIFIED BY '$StratumUserDBPassword';"
Q4="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}${Q3}${Q4}"

# Run SQL statements
sudo mysql -u root -p"${DBRootPassword}" -e "$SQL"

echo
echo -e "$MAGENTA => Creating my.cnf <= ${NC}"

# Create my.cnf based on WireGuard setting
if [[ "$wireguard" == "false" ]]; then
    DB_HOST="localhost"
else
    DB_HOST="$DBInternalIP"
fi

echo "[clienthost1]
user=${YiiMPPanelName}
password=${PanelUserDBPassword}
database=${YiiMPDBName}
host=${DB_HOST}
[clienthost2]
user=${StratumDBUser}
password=${StratumUserDBPassword}
database=${YiiMPDBName}
host=${DB_HOST}
[mysql]
user=root
password=${DBRootPassword}
" | sudo -E tee "$STORAGE_ROOT/yiimp/.my.cnf" >/dev/null 2>&1

sudo chmod 0600 "$STORAGE_ROOT/yiimp/.my.cnf"

echo
echo -e "$YELLOW => Importing YiiMP Default database values <= ${NC}"
cd "$STORAGE_ROOT/yiimp/yiimp_setup/yiimp/sql"

sudo zcat 2024-03-06-complete_export.sql.gz | sudo mysql -u root -p"${DBRootPassword}" "${YiiMPDBName}"

# SQL files
SQL_FILES=(
    2024-03-18-add_aurum_algo.sql
    2024-03-29-add_github_version.sql
    2024-03-31-add_payout_threshold.sql
    2024-04-01-add_auto_exchange.sql
    2024-04-01-shares_blocknumber.sql
    2024-04-05-algos_port_color.sql
    2024-04-22-add_equihash_algos.sql
    2024-04-23-add_pers_string.sql
    2024-04-29-add_sellthreshold.sql
    2024-05-04-add_neoscrypt_xaya_algo.sql
)

for file in "${SQL_FILES[@]}"; do
    if [[ "$file" == *.gz ]]; then
        # Handle gzipped files
        sudo zcat "$file" | sudo mysql -u root -p"${DBRootPassword}" "${YiiMPDBName}" --force --binary-mode
    else
        # Handle regular SQL files
        sudo mysql -u root -p"${DBRootPassword}" "${YiiMPDBName}" --force < "$file"
    fi
done

cd $HOME/Yiimpoolv1/yiimp_single/yiimp_confs
sudo mysql -u root -p"${DBRootPassword}" "${YiiMPDBName}" --force < "2025-01-29-enable-all-algos.sql"

echo
echo -e "$YELLOW <-- Database import $GREEN complete -->${NC}"
echo
echo -e "$YELLOW => Tweaking MariaDB for better performance <= ${NC}"

# Define MariaDB configuration changes
config_changes=(
    '[mysqld]'
    'max_connections=800'
    'thread_cache_size=512'
    'tmp_table_size=128M'
    'max_heap_table_size=128M'
    'wait_timeout=300'
    'max_allowed_packet=64M'
)

# Add bind-address if WireGuard is true
if [[ ("$wireguard" == "true") ]]; then
    config_changes+=("bind-address=$DBInternalIP")
fi

# Prepare the configuration changes as a string with each option on a separate line
config_string=$(printf "%s\n" "${config_changes[@]}")

# Apply changes to MariaDB configuration
sudo bash -c "echo \"$config_string\" >> /etc/mysql/my.cnf"

restart_service mysql

set +eu +o pipefail

cd $HOME/Yiimpoolv1/yiimp_single
