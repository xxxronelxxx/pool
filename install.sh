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

# Default version tag if not provided as environment variable
TAG=${TAG:-v0.1.6}

# File paths
YIIMPOOL_VERSION_FILE="/etc/yiimpoolversion.conf"
YIIMPOOL_INSTALL_DIR="$HOME/Yiimpoolv2"

# Function to log messages to stderr
log_error() {
  echo "[ERROR] $1" >&2
}

# Function to install git if not already installed
install_git() {
  if ! command -v git &>/dev/null; then
    log_error "Git is not installed. Installing git..."
    sudo apt-get -q update
    DEBIAN_FRONTEND=noninteractive sudo apt-get -q install -y git < /dev/null
    echo "Git installed."
  else
    echo "Git is already installed."
  fi
}

# Function to clone or update the Yiimpool installer repository
clone_or_update_repo() {
  if [ ! -d "$YIIMPOOL_INSTALL_DIR" ]; then
    echo "Cloning Yiimpool Installer ${TAG}..."
    git clone -b "${TAG}" --depth 1 https://github.com/afiniel/Yiimpoolv2 "$YIIMPOOL_INSTALL_DIR" < /dev/null
    echo "Repository cloned."
  else
    echo "Updating Yiimpool Installer to ${TAG}..."
    cd "$YIIMPOOL_INSTALL_DIR"
    sudo chown -R "$USER" "$YIIMPOOL_INSTALL_DIR/.git/"
    git fetch --depth 1 --force --prune origin tag "${TAG}"
    if ! git checkout -q "${TAG}"; then
      log_error "Failed to update repository to ${TAG}."
      exit 1
    fi
    echo "Repository updated."
  fi
}

# Function to set the Yiimpool version in configuration file
set_yiimpool_version() {
  echo "VERSION=${TAG}" | sudo tee "$YIIMPOOL_VERSION_FILE" >/dev/null
}

# Function to start the Yiimpool installation script
start_installation() {
  bash "$YIIMPOOL_INSTALL_DIR/install/start.sh"
}

# Main execution starts here

# Ensure the script is run with sudo privileges for setting Yiimpool version
if [[ $EUID -ne 0 ]]; then
  log_error "This script must be run with sudo."
  exit 1
fi

# Perform installation steps
install_git
clone_or_update_repo
set_yiimpool_version
start_installation
