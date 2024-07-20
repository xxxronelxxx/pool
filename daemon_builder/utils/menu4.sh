#!/usr/bin/env bash
#####################################################
# Updated by Afiniel
# Updrade this scrypt
#####################################################

source /etc/daemonbuilder.sh
source $STORAGE_ROOT/daemon_builder/conf/info.sh

if [[ ("${LATESTVER}" > "${VERSION}" && "${LATESTVER}" != "null") ]]; then
	message_box " Updating This script to ${LATESTVER}" \
	"You are currently using version ${VERSION}
	\n\nAre you going to update it to the version ${LATESTVER}"
	TAG="${LATESTVER}"

	cd ~
	clear

	hide_output sudo git config --global url."https://github.com/".insteadOf git@github.com:
	hide_output sudo git config --global url."https://".insteadOf git://
	sleep 1

	REPO="Afiniel/Yiimpoolv1"

	temp_dir="$(tempfile -d)" && \
		git clone -q git@github.com:${REPO%.git} "${temp_dir}" && \
			cd "${temp_dir}/" && \
				git -c advice.detachedHead=false checkout -q tags/${TAG}
	sleep 1
	test $? -eq 0 ||
		{ 
			echo
			echo -e "$RED Error cloning repository. ${NC}";
			echo
			sudo rm -f $temp_dir
			exit 1;
		}
	
	FILEINSTALLEXIST="${temp_dir}/install.sh"
	if [ -f "$FILEINSTALLEXIST" ]; then
		hide_output sudo chown -R $USER ${temp_dir}
		sleep 1
		cd ${temp_dir}
		sudo find . -type f -name "*.sh" -exec chmod -R +x {} \;
		sleep 1
		./install.sh "${temp_dir}"
	fi

	sudo rm -rf $temp_dir

	echo -e "$CYAN  -------------------------------------------------------------------------- 	${NC}"
	echo -e "$GREEN    						Updating is Finish!					 				${NC}"
	echo -e "$CYAN  -------------------------------------------------------------------------- 	${NC}"
	echo
	cd ~
	exit

else
	message_box " Updating This script " \
	"Check if this scrypt needs update.
	\nyou already have the latest version installed!
	\nYour Version is: ${VERSION}"

	cd ~
	clear
	echo -e "$CYAN  -------------------------------------------------------------------------- 	${NC}"
	echo -e "$RED    Thank you using this scrpt!			 				${NC}"
	echo -e "$CYAN  -------------------------------------------------------------------------- 	${NC}"
	echo
	echo -e "$CYAN  -------------------------------------------------------------------------- 	${NC}"
	echo -e "$GREEN	Donations are welcome at wallets below:					  					${NC}"
	echo -e "$YELLOW  BTC: ${NC} $MAGENTA ${BTCDEP}	${NC}"
	echo -e "$YELLOW  LTC: ${NC} $MAGENTA ${LTCDEP}	${NC}"
	echo -e "$YELLOW  ETH: ${NC} $MAGENTA ${ETHDEP}	${NC}"
	echo -e "$YELLOW  BCH: ${NC} $MAGENTA ${DOGEDEP}	${NC}"
	echo -e "$CYAN  -------------------------------------------------------------------------- 	${NC}"
	echo
	cd ~
	exit

fi

