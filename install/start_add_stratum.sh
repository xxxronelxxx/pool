#!/bin/env bash

source /etc/functions.sh
source /etc/yiimpool.conf


cd $HOME/Yiimpoolv1/install

source questions_add_stratum.sh
clear
source add_stratum_db.sh
source setsid_stratum_server.sh

echo "Stratum server added successfully"

cd ~
clear
exit 0
