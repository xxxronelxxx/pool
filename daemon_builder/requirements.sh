#!/bin/env bash

#
# Author: Afiniel
# Date: 2023-01-12
# 
# Description: This install all requirements for DaemonBuilder.
# 

# Load required functions and configurations
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

print_header "DaemonBuilder Requirements Setup"

print_status "Setting up DaemonBuilder utilities..."
cd $HOME/Yiimpoolv1/daemon_builder
hide_output sudo cp -r $HOME/Yiimpoolv1/daemon_builder/utils/screen-scrypt-daemonbuilder.sh /etc/
hide_output sudo chmod +x /etc/screen-scrypt-daemonbuilder.sh
print_success "DaemonBuilder utilities configured"

print_header "Core Development Packages"
print_status "Installing essential build packages..."
hide_output sudo apt-get update
hide_output sudo apt-get -y upgrade
hide_output sudo apt-get -y install p7zip-full

print_status "Installing core development libraries..."
apt_install build-essential libzmq5 libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils \
cmake libboost-all-dev zlib1g-dev libseccomp-dev libcap-dev libminiupnpc-dev gettext libcanberra-gtk-module \
libqrencode-dev libzmq3-dev libqt5gui5 libqt5core5a libqt5webkit5-dev libqt5dbus5 qttools5-dev qttools5-dev-tools \
libprotobuf-dev protobuf-compiler libleveldb-dev bison
print_success "Core development packages installed"

print_header "Database Dependencies"
if [[ ("${DISTRO}" == "18") ]]; then
	print_status "Installing Ubuntu 18.04 specific packages..."
	apt_install libz-dev libminiupnpc10
	
	print_status "Adding Bitcoin repository..."
	hide_output sudo add-apt-repository -y ppa:bitcoin/bitcoin
	hide_output sudo apt-get update
	hide_output sudo apt-get -y upgrade
	
	print_status "Installing Berkeley DB..."
	apt_install libdb4.8-dev libdb4.8++-dev libdb5.3 libdb5.3++
	print_success "Ubuntu 18.04 specific packages installed"
fi


hide_output sudo apt -y install libdb5.3 libdb5.3++


print_header "Additional System Libraries"
print_status "Installing extended development packages..."
hide_output sudo apt-get update

print_status "Installing cryptocurrency-specific libraries..."
apt_install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev libboost-all-dev \
libminiupnpc-dev libqt5gui5 libqt5core5a libqt5webkit5-dev libqt5dbus5 qttools5-dev qttools5-dev-tools \
libprotobuf-dev protobuf-compiler libqrencode-dev libzmq3-dev libgmp-dev cmake libunbound-dev libsodium-dev \
libunwind8-dev liblzma-dev libreadline6-dev libldns-dev libexpat1-dev libpgm-dev libhidapi-dev libusb-1.0-0-dev \
libudev-dev libboost-chrono-dev libboost-date-time-dev libboost-filesystem-dev libboost-locale-dev \
libboost-program-options-dev libboost-regex-dev libboost-serialization-dev libboost-system-dev libboost-thread-dev \
python3 ccache doxygen graphviz default-libmysqlclient-dev libnghttp2-dev librtmp-dev libssh2-1 libssh2-1-dev \
libldap2-dev libidn11-dev libpsl-dev libnatpmp-dev systemtap-sdt-dev qtwayland5 ibsqlite3-dev

if [[ ("${DISTRO}" == "18") ]]; then
	print_status "Installing SQLite for Ubuntu 18.04..."
	hide_output sudo apt -y install ibsqlite3-dev
else
	print_status "Installing additional database libraries..."
	hide_output sudo apt -y install libdb-dev
	hide_output sudo apt -y install libdb5.3++ libdb5.3++-dev
fi

print_success "All system libraries installed successfully"

print_header "Installation Summary"
print_info "Core Development Tools: Installed"
print_info "Database Dependencies: Configured"
print_info "System Libraries: Complete"
print_info "Build Essentials: Ready"
print_success "DaemonBuilder requirements installation completed"

print_divider

set +eu +o pipefail
cd $HOME/Yiimpoolv1/daemon_builder
source $HOME/Yiimpoolv1/daemon_builder/berkeley.sh