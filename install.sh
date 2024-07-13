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

# Set the default TAG if not provided
TAG=${TAG:-v0.0.3}

# Create the yiimpoolversion.conf file
echo "VERSION=${TAG}" | sudo tee /etc/yiimpoolversion.conf >/dev/null

# Function to install git if it's not already installed
install_git() {
  if ! command -v git &>/dev/null; then
    echo "Installing git..."
    apt-get -q update
    DEBIAN_FRONTEND=noninteractive apt-get -q install -y git
    echo "Git installed."
  fi
}

# Function to clone the Yiimpool installer repository
clone_repo() {
  if [ ! -d "$HOME/Yiimpoolv2" ]; then
    echo "Downloading Yiimpool Installer ${TAG}..."
    git clone -b "${TAG}" --depth 1 https://github.com/afiniel/Yiimpoolv2 "$HOME/Yiimpoolv2"
    echo "Repository cloned."
  fi
}

# Function to update the Yiimpool installer repository
update_repo() {
  cd "$HOME/Yiimpoolv2"

  sudo chown -R "$USER" "$HOME/Yiimpoolv2/.git/"
  if [ "${TAG}" != "$(git describe --tags)" ]; then
    echo "Updating Yiimpool Installer to ${TAG}..."
    git fetch --depth 1 --force --prune origin tag "${TAG}"
    if ! git checkout -q "${TAG}"; then
      echo "Update failed. Did you modify something in $(pwd)?"
      exit 1
    fi
    echo "Repository updated."
  fi
}

# Include the functions file
#source "$HOME/yiimp_install_script/functions.sh"

install_git
clone_repo
update_repo
start_installation