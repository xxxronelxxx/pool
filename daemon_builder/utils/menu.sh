#!/bin/env bash

#
# This is the main menu For Daemon Builder
#
# Author: Afiniel
#
# Updated: 2025-01-29
#

source /etc/daemonbuilder.sh
source "$STORAGE_ROOT/daemon_builder/conf/info.sh"

cd "$STORAGE_ROOT/daemon_builder" || exit

LATESTVER=$(curl -sL 'https://api.github.com/repos/Afiniel/Yiimpoolv1/releases/latest' | jq -r '.tag_name')

if [[ "${LATESTVER}" > "${VERSION}" && "${LATESTVER}" != "null" ]]; then
    echo "New version available: ${LATESTVER}"
    echo "Your version: ${VERSION}"
    echo "Do you want to update? (y/n)"
    read -r UPDATE
    if [[ "${UPDATE}" == "y" || "${UPDATE}" == "Y" ]]; then
        echo "Updating..."
        cd "$HOME/Yiimpoolv1" || exit
        git pull
        echo "Update complete!"
        exit 0
    fi
fi

RESULT=$(dialog --stdout --title "DaemonBuilder $VERSION" --menu "Choose an option" 20 60 4 \
    1 "Build Coin Daemon From Source Code" \
    2 "Update Coin Daemon" \
    3 "Exit DaemonBuilder")

case "$RESULT" in
    1)
        clear
        cd "$STORAGE_ROOT/daemon_builder"
        source menu1.sh
        ;;
    2)
        clear
        cd "$STORAGE_ROOT/daemon_builder"
        source menu2.sh
        ;;
    3)
        clear
        echo -e "$CYAN ------------------------------------------------------------------------------- $NC"
        echo -e "$YELLOW You have chosen to exit the Daemon Builder.$NC"
        echo -e "$YELLOW Type: $BLUE daemonbuilder $YELLOW anytime to start the menu again.$NC"
        echo -e "$CYAN ------------------------------------------------------------------------------- $NC"
        exit;
        ;;
esac