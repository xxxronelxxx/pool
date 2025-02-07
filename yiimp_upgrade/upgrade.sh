#!/usr/bin/env bash

source /etc/functions.sh
source /etc/yiimpool.conf
source /etc/yiimpoolversion.conf
source $HOME/Yiimpoolv1/yiimp_upgrade/utils/functions.sh

UPGRADE_TYPE="full"
if [ "$1" == "--stratum-only" ]; then
    UPGRADE_TYPE="stratum"
fi

main() {
    log_message "$YELLOW" "Starting Yiimpool upgrade process..."
    log_message "$YELLOW" "Upgrade type: $UPGRADE_TYPE"
    
    if ! verify_requirements; then
        log_message "$RED" "System requirements not met. Aborting upgrade."
        exit 1
    fi
    
    backup_system
    
    case "$UPGRADE_TYPE" in
        "full")
            echo "VERSION=$LATEST_TAG" | sudo tee /etc/yiimpoolversion.conf >/dev/null
            log_message "$YELLOW" "Updating installation files..."
            cd $HOME/Yiimpoolv1
            sudo git pull
            ;;
        "stratum")
            upgrade_stratum
            log_message "$GREEN" "Yiimpool upgrade completed successfully!"
            ;;
    esac
}

main 