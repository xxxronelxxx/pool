#!/bin/env bash

#
# Author: Afiniel
# Date: 2023-01-12
#
# Updated 2024-07-15
# Description: Installs all requirements for DaemonBuilder.
#

# Load functions and configurations
source /etc/functions.sh
source /etc/yiimpool.conf
source "$STORAGE_ROOT/yiimp/.yiimp.conf"

set -euo pipefail

function print_error {
    read line file <<<$(caller)
    echo "An error occurred in line $line of file $file:" >&2
    sed "${line}q;d" "$file" >&2
}
trap print_error ERR

# Change directory to DaemonBuilder
cd "$HOME/Yiimpoolv1/daemon_builder"

# Copy screen-scrypt-daemonbuilder.sh and set permissions
hide_output sudo cp -r "$HOME/Yiimpoolv1/daemon_builder/utils/screen-scrypt-daemonbuilder.sh" /etc/
hide_output sudo chmod +x /etc/screen-scrypt-daemonbuilder.sh

if [[ "${DISTRO}" == "18" ]]; then
    apt_install libz-dev libminiupnpc10
    hide_output sudo add-apt-repository -y ppa:bitcoin/bitcoin
    hide_output sudo apt-get update
    hide_output sudo apt-get -y upgrade
    apt_install libdb4.8-dev libdb4.8++-dev libdb5.3 libdb5.3++
fi

hide_output sudo apt -y install libdb5.3 libdb5.3++
echo -e "$GREEN => Installation complete <=${NC}"

echo -e "\n$MAGENTA => Installing additional system files required for daemons <= ${NC}"
hide_output sudo apt-get update
apt_install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev libboost-all-dev libminiupnpc-dev \
    libqt5gui5 libqt5core5a libqt5webkit5-dev libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler \
    libqrencode-dev libzmq3-dev libgmp-dev cmake libunbound-dev libsodium-dev libunwind8-dev liblzma-dev libreadline6-dev \
    libldns-dev libexpat1-dev libpgm-dev libhidapi-dev libusb-1.0-0-dev libudev-dev libboost-chrono-dev libboost-date-time-dev \
    libboost-filesystem-dev libboost-locale-dev libboost-program-options-dev libboost-regex-dev libboost-serialization-dev \
    libboost-system-dev libboost-thread-dev python3 ccache doxygen graphviz default-libmysqlclient-dev libnghttp2-dev \
    librtmp-dev libssh2-1 libssh2-1-dev libldap2-dev libidn11-dev libpsl-dev libnatpmp-dev systemtap-sdt-dev qtwayland5

if [[ "${DISTRO}" == "18" ]]; then
    hide_output sudo apt -y install libsqlite3-dev
else
    hide_output sudo apt -y install libdb-dev
    hide_output sudo apt -y install libdb5.3++ libdb5.3++-dev
fi

echo -e "$GREEN => Additional system files installation complete <=${NC}"

# Update gcc & g++ to version 8
echo -e "\n$CYAN => Updating gcc & g++ to version 8 ${NC}"
hide_output sudo apt-get update
hide_output sudo apt-get -y upgrade
apt_dist_upgrade

apt_install software-properties-common

if [[ "${DISTRO}" == "18" ]]; then
    hide_output sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
fi
hide_output sudo apt-get update

apt_install gcc-8 g++-8

hide_output sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 60 --slave /usr/bin/g++ g++ /usr/bin/g++-8
hide_output sudo update-alternatives --config gcc

echo -e "$GREEN => gcc & g++ updated to version 8 <=${NC}"

set +euo pipefail

# Return to DaemonBuilder directory and source berkeley.sh
cd "$HOME/Yiimpoolv1/daemon_builder"
source "$HOME/Yiimpoolv1/daemon_builder/berkeley.sh"
