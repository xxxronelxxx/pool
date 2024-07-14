#!/usr/bin/env bash
#####################################################
# Updated by Afiniel
# Menu: Add Coin to Dedicated Port and run stratum
#####################################################

source /etc/daemonbuilder.sh
source $STORAGE_ROOT/daemon_builder/conf/info.sh

cd ~
clear

sudo addport

echo -e "$CYAN --------------------------------------------------------------------------- 	${NC}"
echo -e "$RED    Type ${daemonname} at anytime to Add Port & run Stratum				${NC}"
echo -e "$CYAN --------------------------------------------------------------------------- 	${NC}"
exit
