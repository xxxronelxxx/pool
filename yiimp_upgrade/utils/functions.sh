#!/usr/bin/env bash

#####################################################
# Created by Afiniel for Yiimpool use
#
# This script contains utility functions for the upgrade process
#
# Author: Afiniel
# Date: 2024-07-15
#####################################################

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[1;34m'
NC='\033[0m'

STRATUM_DIR="/home/crypto-data/yiimp/site/stratum"
STRATUM_CONF="/home/crypto-data/yiimp/site/stratum/config"
SITE_DIR="/home/crypto-data/yiimp/site"
BACKUP_DIR="$HOME/yiimpool_backups"

log_message() {
    local level=$1
    local message=$2
    echo -e "${level}[$(date '+%Y-%m-%d %H:%M:%S')] ${message}${NC}"
}

check_services() {
    local services=("nginx" "mysql" "php8.1-fpm")
    local all_running=true
    
    for service in "${services[@]}"; do
        if ! systemctl is-active --quiet "$service"; then
            log_message "$RED" "Service $service is not running"
            all_running=false
        fi
    done
    
    if [ "$all_running" = true ]; then
        log_message "$GREEN" "All required services are running"
        return 0
    else
        return 1
    fi
}

verify_requirements() {
    log_message "$YELLOW" "Verifying system requirements..."
    
    local free_space=$(df -m / | awk 'NR==2 {print $4}')
    if [ "$free_space" -lt 5000 ]; then
        log_message "$RED" "Not enough disk space. At least 5GB required."
        return 1
    fi
    
    local free_mem=$(free -m | awk 'NR==2 {print $4}')
    if [ "$free_mem" -lt 1024 ]; then
        log_message "$RED" "Not enough free memory. At least 1GB required."
        return 1
    fi
    
    if ! check_services; then
        return 1
    fi
    
    log_message "$GREEN" "System requirements verified"
    return 0
}

backup_system() {
    log_message "$YELLOW" "Creating system backup..."
    
    local backup_name="yiimpool_backup_$(date +%Y%m%d_%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    sudo mkdir -p "$backup_path"
    sudo cp -r /etc/yiimpool* "$backup_path/"
    
    if [ -d "$SITE_DIR" ]; then
        sudo cp -r "$SITE_DIR/configuration" "$backup_path/site_config"
        sudo cp -r "$SITE_DIR/stratum/config" "$backup_path/stratum_config"
    fi
    
    if command -v mysqldump &>/dev/null; then
        if [ -f "/root/.my.cnf" ]; then
            sudo mysqldump --defaults-file=/root/.my.cnf --all-databases > "$backup_path/database_backup.sql"
        fi
    fi
    
    cd "$BACKUP_DIR"
    sudo tar -czf "${backup_name}.tar.gz" "$backup_name"
    sudo rm -rf "$backup_name"
    
    log_message "$GREEN" "Backup completed: ${backup_name}.tar.gz"
}

upgrade_stratum() {
    log_message "$YELLOW" "Upgrading stratum..."
    
    if [ -f "$STORAGE_ROOT/yiimp/.yiimp.conf" ]; then
        source $STORAGE_ROOT/yiimp/.yiimp.conf
    else
        log_message "$RED" "YiiMP configuration file not found. Exiting..."
        return 1
    fi
    
    if [ -z "$YiiMPRepo" ]; then
        log_message "$RED" "YiiMP repository URL not found in configuration. Exiting..."
        return 1
    fi
    
    YIIMP_DIR="$STORAGE_ROOT/yiimp/yiimp_setup/yiimp"
    
    if [ -d "$STRATUM_CONF" ]; then
        log_message "$GREEN" "Backing up stratum configuration..."
        BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        sudo cp -r "$STRATUM_CONF" "${STRATUM_CONF}_backup_${BACKUP_TIMESTAMP}"
        
        if [ -f "$STRATUM_CONF/stratum.conf" ]; then
            sudo cp "$STRATUM_CONF/stratum.conf" "${STRATUM_CONF}/stratum.conf.backup_${BACKUP_TIMESTAMP}"
        fi
    else
        log_message "$RED" "Stratum configuration directory not found at $STRATUM_CONF"
        return 1
    fi
    
    if [[ -d "$YIIMP_DIR" ]]; then
        sudo rm -rf "$YIIMP_DIR"
    fi
    
    log_message "$GREEN" "Cloning fresh YiiMP repository from $YiiMPRepo..."
    if ! sudo git clone "${YiiMPRepo}" "$YIIMP_DIR"; then
        log_message "$RED" "Failed to clone YiiMP repository. Exiting..."
        return 1
    fi
    
    log_message "$GREEN" "Setting gcc to version 9..."
    hide_output sudo update-alternatives --set gcc /usr/bin/gcc-9
    
    cd $YIIMP_DIR/stratum || {
        log_message "$RED" "Failed to change to stratum directory. Exiting..."
        return 1
    }
    
    sudo git submodule init
    sudo git submodule update
    
    cd secp256k1 || {
        log_message "$RED" "Failed to change to secp256k1 directory. Exiting..."
        return 1
    }
    
    sudo chmod +x autogen.sh
    hide_output sudo ./autogen.sh
    hide_output sudo ./configure --enable-experimental --enable-module-ecdh --with-bignum=no --enable-endomorphism
    hide_output sudo make -j$((`nproc`+1))
    
    cd $YIIMP_DIR/stratum || {
        log_message "$RED" "Failed to return to stratum directory. Exiting..."
        return 1
    }
    
    log_message "$GREEN" "Building stratum components..."
    
    if ! sudo make -C algos -j$(($(nproc)+1)); then
        log_message "$RED" "Failed to build algos. Please check the build output above for errors."
        return 1
    fi
    log_message "$GREEN" "algos built successfully!"
    
    if ! sudo make -C sha3 -j$(($(nproc)+1)); then
        log_message "$RED" "Failed to build sha3. Please check the build output above for errors."
        return 1
    fi
    log_message "$GREEN" "sha3 built successfully!"
    
    if ! sudo make -C iniparser -j$(($(nproc)+1)); then
        log_message "$RED" "Failed to build iniparser. Please check the build output above for errors."
        return 1
    fi
    log_message "$GREEN" "iniparser built successfully!"
    
    if ! sudo make -j$(($(nproc)+1)); then
        log_message "$RED" "Failed to build stratum. Please check the build output above for errors."
        return 1
    fi
    log_message "$GREEN" "stratum built successfully!"
    
    log_message "$GREEN" "Installing stratum..."
    if ! sudo mv stratum "$STRATUM_DIR/"; then
        log_message "$RED" "Failed to install stratum."
        return 1
    fi
    
    sudo chown www-data:www-data "$STRATUM_DIR/stratum"
    sudo chmod 750 "$STRATUM_DIR/stratum"
    
    sudo mkdir -p "$STRATUM_CONF"
    
    log_message "$GREEN" "Restoring stratum configuration..."
    LATEST_BACKUP=$(ls -td "${STRATUM_CONF}_backup_"* | head -1)
    if [ -d "$LATEST_BACKUP" ]; then
        sudo cp -r "$LATEST_BACKUP/"* "$STRATUM_CONF/"
        sudo chown -R www-data:www-data "$STRATUM_CONF"
        sudo chmod -R 750 "$STRATUM_CONF"
        log_message "$GREEN" "Stratum configuration restored from $LATEST_BACKUP"
    fi
    
    cd $YIIMP_DIR/web/yaamp/core/functions/
    sudo cp -r yaamp.php $SITE_DIR/web/yaamp/core/functions
    
    hide_output sudo update-alternatives --set gcc /usr/bin/gcc-10
    
    log_message "$GREEN" "Stratum upgrade completed successfully!"
    return 0
}

verify_upgrade() {
    log_message "$YELLOW" "Verifying upgrade..."
    
    if ! check_services; then
        log_message "$RED" "Service check failed after upgrade"
        return 1
    fi
    
    log_message "$GREEN" "Upgrade verification completed successfully"
    return 0
}

restore_from_backup() {
    local backup_file=$1
    
    if [ ! -f "$backup_file" ]; then
        log_message "$RED" "Backup file not found: $backup_file"
        return 1
    fi
    
    log_message "$YELLOW" "Restoring from backup: $backup_file"
    
    sudo systemctl stop nginx php8.1-fpm
    
    cd "$BACKUP_DIR"
    sudo tar -xzf "$backup_file"
    
    local backup_dir="${backup_file%.tar.gz}"
    
    sudo cp -r "$backup_dir/yiimpool"* /etc/
    
    if [ -d "$backup_dir/site_config" ]; then
        sudo cp -r "$backup_dir/site_config"/* "$SITE_DIR/configuration/"
    fi
    
    if [ -d "$backup_dir/stratum_config" ]; then
        sudo cp -r "$backup_dir/stratum_config"/* "$SITE_DIR/stratum/config/"
    fi
    
    sudo rm -rf "$backup_dir"
    
    sudo systemctl start nginx php8.1-fpm
    
    log_message "$GREEN" "Restore completed"
    return 0
} 