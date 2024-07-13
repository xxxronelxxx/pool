#!/usr/bin/env bash

#########################################################
# Functions for Yiimpool Installer Script
#
# Author: Afiniel
# Date: 2024-07-13
#########################################################

# Colors And Spinner.

ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
RED=$ESC_SEQ"31;01m"
GREEN=$ESC_SEQ"32;01m"
YELLOW=$ESC_SEQ"33;01m"
BLUE=$ESC_SEQ"34;01m"
MAGENTA=$ESC_SEQ"35;01m"
CYAN=$ESC_SEQ"36;01m"

spinner() {
    local pid=$!
    local delay=0.35
    local spinstr='|/-\'
    while ps a | awk '{print $1}' | grep -q $pid; do
        local temp=${spinstr#?}
        printf " [%c] " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}


# Install.sh functions.

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

# MESSAGE BOX FUNCTIONS.

# Function to start the Yiimpool installation script
start_installation() {
  bash "$HOME/Yiimpoolv2/install/start.sh"
}

# Function to display messages in a dialog box

message_box() {
    local title="$1"
    local message="$2"
    dialog --title "$title" --msgbox "$message" 10 60
}

# Function to display input box and store user input
input_box() {
    local title="$1"
    local prompt="$2"
    local default="$3"
    local variable="$4"
    dialog --title "$title" --inputbox "$prompt" 10 60 "$default" 2> >(read -r "$variable")
}

hide_output() {
    local OUTPUT=$(mktemp)
    $@ &>$OUTPUT &
    local pid=$!

    # Run spinner function in the background
    spinner $pid

    local E=$?
    wait $pid # Wait for the background process to finish
    local exit_status=$?

    if [ $exit_status != 0 ]; then
        echo " "
        echo "FAILED: $@"
        echo "-----------------------------------------"
        cat $OUTPUT
        echo "-----------------------------------------"
        rm -f $OUTPUT
        exit $exit_status
    fi

    rm -f $OUTPUT
}

apt_get_quiet() {
    DEBIAN_FRONTEND=noninteractive hide_output sudo apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" "$@"
}

