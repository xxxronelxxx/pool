#!/usr/bin/env bash

#
# This is the option update coin daemon menu
#
# Author: Afiniel
#
# Updated: 2025-01-29
#

source /etc/daemonbuilder.sh
source $STORAGE_ROOT/daemon_builder/conf/info.sh

cd "$STORAGE_ROOT/daemon_builder"

RESULT=$(dialog --stdout --title "DaemonBuilder $VERSION" --menu "Choose an option" 16 60 9 \
    1 "Berkeley 4.8" \
    2 "Berkeley 5.1" \
    3 "Berkeley 5.3" \
    4 "Berkeley 6.2" \
    5 "Makefile.unix" \
    6 "CMake file & DEPENDS folder" \
    7 "UTIL folder contains BULD.sh" \
    8 "Precompiled coin. NEED TO BE LINUX Version!" \
    9 "Exit DaemonBuilder")

case "$RESULT" in
    1)
        clear;
        echo '
        berkeley="4.8"
        ' | sudo -E tee $STORAGE_ROOT/daemon_builder/.daemon_builder.my.cnf >/dev/null 2>&1;
        source upgrade.sh;
        ;;
    2)
        clear;
        echo '
        berkeley="5.1"
        ' | sudo -E tee $STORAGE_ROOT/daemon_builder/.daemon_builder.my.cnf >/dev/null 2>&1;
        source upgrade.sh;
        ;;
    3)
        clear;
        echo '
        berkeley="5.3"
        ' | sudo -E tee $STORAGE_ROOT/daemon_builder/.daemon_builder.my.cnf >/dev/null 2>&1;
        source upgrade.sh;
        ;;
    4)
        clear;
        echo '
        berkeley="6.2"
        ' | sudo -E tee $STORAGE_ROOT/daemon_builder/.daemon_builder.my.cnf >/dev/null 2>&1;
        source upgrade.sh;
        ;;
    5)
        clear;
        echo '
        berkeley="Makefile.unix"
        ' | sudo -E tee $STORAGE_ROOT/daemon_builder/.daemon_builder.my.cnf >/dev/null 2>&1;
        source upgrade.sh;
        ;;
    6)
        clear;
        echo '
        berkeley="CMake file & DEPENDS folder"
        ' | sudo -E tee $STORAGE_ROOT/daemon_builder/.daemon_builder.my.cnf >/dev/null 2>&1;
        source upgrade.sh;
        ;;
    7)
        clear;
        echo '
        berkeley="UTIL folder contains BULD.sh"
        ' | sudo -E tee $STORAGE_ROOT/daemon_builder/.daemon_builder.my.cnf >/dev/null 2>&1;
        source upgrade.sh;
        ;;
    8)
        clear;
        echo '
        berkeley="Precompiled coin. NEED TO BE LINUX Version!"
        ' | sudo -E tee $STORAGE_ROOT/daemon_builder/.daemon_builder.my.cnf >/dev/null 2>&1;
        source upgrade.sh;
        ;;
    9)
        clear;
        exit;
        ;;
esac


