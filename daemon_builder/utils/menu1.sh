#!/bin/env bash

#
# This is the main menu For Daemon Builder
#
# Author: Afiniel
#
# Updated: 2024-01-03
#

source /etc/daemonbuilder.sh

source $STORAGE_ROOT/daemon_builder

RESULT=$(dialog --stdout --title "DaemonBuilder $VERSION" --menu "Choose an option" 16 60 9 \
    ' ' "- Install coin with Berkeley autogen file -" \
    1 "Berkeley 4.8" \
    2 "Berkeley 5.1" \
    3 "Berkeley 5.3" \
    4 "Berkeley 6.2" \
    ' ' "- Other choices -" \
    5 "Install coin with makefile.unix file" \
    6 "Install coin with CMake file & DEPENDS folder" \
    7 "Install coin with UTIL folder contains BULD.sh" \
    8 "Install precompiled coin. NEED TO BE LINUX Version!" \
    9 exit)

if [ "$RESULT" = "1" ]; then
    clear;
    echo '
    autogen=true
    berkeley="4.8"
    ' | sudo -E tee $STORAGE_ROOT/daemon_builder/.daemon_builder.my.cnf >/dev/null 2>&1;
    source source.sh;

elif [ "$RESULT" = "2" ]; then
    clear;
    echo '
    autogen=true
    berkeley="5.1"
    ' | sudo -E tee $STORAGE_ROOT/daemon_builder/.daemon_builder.my.cnf >/dev/null 2>&1;
    source source.sh;

elif [ "$RESULT" = "3" ]; then
    clear;
    echo '
    autogen=true
    berkeley="5.3"
    ' | sudo -E tee $STORAGE_ROOT/daemon_builder/.daemon_builder.my.cnf >/dev/null 2>&1;
    source source.sh;

elif [ "$RESULT" = "4" ]; then
    clear;
    echo '
    autogen=true
    berkeley="6.2"
    ' | sudo -E tee $STORAGE_ROOT/daemon_builder/.daemon_builder.my.cnf >/dev/null 2>&1;
    source source.sh;

elif [ "$RESULT" = "5" ]; then
    clear;
    echo '
    autogen=false
    unix=true
    ' | sudo -E tee $STORAGE_ROOT/daemon_builder/.daemon_builder.my.cnf >/dev/null 2>&1;
    source source.sh;

elif [ "$RESULT" = "6" ]; then
    clear;
    echo '
    autogen=false
    cmake=true
    ' | sudo -E tee $STORAGE_ROOT/daemon_builder/.daemon_builder.my.cnf >/dev/null 2>&1;
    source source.sh;

    elif [ "$RESULT" = "7" ]; then
    clear;
    echo '
    buildutil=true
    autogen=true
    ' | sudo -E tee $STORAGE_ROOT/daemon_builder/.daemon_builder.my.cnf >/dev/null 2>&1;
    source source.sh;

elif [ "$RESULT" = "8" ]; then
    clear;
    echo '
    precompiled=true
    ' | sudo -E tee $STORAGE_ROOT/daemon_builder/.daemon_builder.my.cnf >/dev/null 2>&1;
    source source.sh;

elif [ "$RESULT" = "9" ]; then
    clear;
    echo "You have chosen to exit the Daemon Builder. Type: daemonbuilder anytime to start the menu again.";
    exit;
fi