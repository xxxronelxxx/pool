#!/usr/bin/env bash

#########################################################
# Functions for Yiimpool Installer Script
#
# Author: Afiniel
# Date: 2024-07-13
#########################################################

# Colors And Spinner.

ESC_SEQ="\x1b["
NC='\033[0m' # No Color
RED=$ESC_SEQ"31;01m"
GREEN=$ESC_SEQ"32;01m"
YELLOW=$ESC_SEQ"33;01m"
BLUE=$ESC_SEQ"34;01m"
MAGENTA=$ESC_SEQ"35;01m"
CYAN=$ESC_SEQ"36;01m"

spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    local start_time=$(date +%s)
    local SECONDS=0  # Initialize timer
    local total_seconds=300  # Example total duration of the process in seconds (adjust as needed)

    while ps -p $pid > /dev/null; do
        local current_time=$(date +%s)
        local elapsed_seconds=$((current_time - start_time))
        
        # Calculate progress percentage
        local progress=$(( (elapsed_seconds * 100) / total_seconds ))
        if [ $progress -gt 100 ]; then
            progress=100
        fi
        
        local remaining_seconds=$(( total_seconds - elapsed_seconds ))
        
        local hours=$((remaining_seconds / 3600))
        local minutes=$(( (remaining_seconds % 3600) / 60 ))
        local seconds=$((remaining_seconds % 60))

        # Print elapsed time and estimated time remaining (ETA)
        printf "\r[Elapsed: %02d:%02d:%02d] [ETA: %02d:%02d:%02d] [%c] %d%%" \
            $((elapsed_seconds / 3600)) $(( (elapsed_seconds % 3600) / 60 )) $((elapsed_seconds % 60)) \
            $hours $minutes $seconds \
            "${spinstr:0:1}" \
            $progress

        # Rotate spinner animation
        spinstr=${spinstr:1}${spinstr:0:1}
        sleep $delay
    done

    printf "\r                        \r"  # Clear timer, spinner, and ETA
}



# MESSAGE BOX FUNCTIONS.

# Function to display messages in a dialog box

# Welcome message
message_box() {
    title="$1"
    message="$2"
    echo -e "${YELLOW}$title${COL_RESET}"
    echo -e "${GREEN}$message${COL_RESET}"
}

# Function to display input box and store user input
function input_box {
	# Usage: input_box "title" "prompt" "defaultvalue" VARIABLE
	# 
	# Prompts the user with a dialog input box.
	# Parameters:
	#   $1: Title of the dialog box
	#   $2: Prompt message
	#   $3: Default value (optional)
	#   $4: Variable to store user input
	# 
	# Outputs:
	#   The user's input will be stored in the variable specified by $4.
	#   The exit code from dialog will be stored in ${4}_EXITCODE.
	
	local result
	local result_code
	declare -n result_var="$4"
	declare -n result_code_var="${4}_EXITCODE"
	
	result=$(dialog --stdout --title "$1" --inputbox "$2" 0 0 "$3")
	result_code=$?
	
	# Assigning the result to the variable specified by $4
	result_var="$result"
	
	# Storing the exit code from dialog in ${4}_EXITCODE
	result_code_var=$result_code
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

