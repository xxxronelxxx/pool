#!/usr/bin/env bash

#########################################################
#
# This script performs the following tasks:
# 1. Sets the version tag for the Yiimpoolv2 installation.
# 2. Checks and installs git if it's not already installed.
# 3. Clones the Yiimpoolv2 installer repository from GitHub.
# 4. Updates the repository to the specified version tag if necessary.
# 5. Starts the Yiimpoolv2 installation process.
#
# Author: Afiniel
# Date: 2024-07-13
#
#########################################################

set -e

# Include the functions file
source "$HOME/yiimp_install_script/functions.sh"

# Set the default TAG if not provided
TAG=${TAG:-v0.0.1}

# Main script execution
echo "VERSION=${TAG}" | sudo tee /etc/yiimpoolversion.conf >/dev/null

install_git
clone_repo
update_repo
start_installation