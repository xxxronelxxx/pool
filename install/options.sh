#!/bin/env bash

#####################################################
# Source code https://github.com/end222/pacmenu
# Updated by Afiniel for crypto use...
#####################################################

source /etc/functions.sh

#!/bin/env bash

#
# YiimPool Options menu
#
# Author: Afiniel
# Updated: 2025-02-01
#

# Load configuration and functions
source /etc/yiimpooldonate.conf
source /etc/functions.sh

# Display menu and capture user selection
RESULT=$(dialog --stdout --nocancel --default-item 1 --title "YiimPool Menu $VERSION" --menu "Choose an option" -1 55 7 \
    1 "Add Stratum Server" \
    2 "Exit")

case "$RESULT" in
    1)
        clear
        #echo "Preparing to add a new stratum server..."
        #source start_add_stratum.sh
        echo "Not Enabled Yet.. to be added soon"
        ;;
    2)
        clear
        exit
        ;;
esac