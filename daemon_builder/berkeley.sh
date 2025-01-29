#!/usr/bin/env bash

##################################################################################
# This is the entry point for configuring the system.                            #
#
# Updated by Afiniel for Yiimpool use...                                         #
##################################################################################

# Update configuration file with dependencies


sleep 1
sudo sed -i 's#absolutepathserver#'"$absolutepath"'#' conf/daemonbuilder.sh

# Source configuration files
source /etc/yiimpoolversion.conf
source /etc/functions.sh
source /etc/yiimpool.conf

# Set variables
STRATUM_DIR="$STORAGE_ROOT/yiimp/site/stratum"
FUNCTIONFILE="daemonbuilder.sh"
TAG="$VERSION"

# Create temporary directory
sudo mkdir -p $STORAGE_ROOT/yiimp/yiimp_setup/tmp
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp

echo -e "\n$GREEN => Additional System Files Completed <= ${NC}"

# Build BerkeleyDB 4.8
echo -e "\n$MAGENTA => Building Berkeley 4.8 <= ${NC}"
sudo mkdir -p $STORAGE_ROOT/berkeley/db4/
hide_output sudo wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
hide_output sudo tar -xzvf db-4.8.30.NC.tar.gz
sudo sed -i 's/__atomic_compare_exchange/__atomic_compare_exchange_db/g' db-4.8.30.NC/dbinc/atomic.h
cd db-4.8.30.NC/build_unix/
hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=/home/crypto-data/berkeley/db4
hide_output sudo make -j$((`nproc`+1))
hide_output sudo make install -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r db-4.8.30.NC.tar.gz db-4.8.30.NC
echo -e "$GREEN => Berkeley 4.8 Completed <= ${NC}"

# Build BerkeleyDB 5.1
echo -e "\n$MAGENTA => Building Berkeley 5.1 <= ${NC}"
sudo mkdir -p $STORAGE_ROOT/berkeley/db5.1/
hide_output sudo wget 'http://download.oracle.com/berkeley-db/db-5.1.29.tar.gz'
hide_output sudo tar -xzvf db-5.1.29.tar.gz
sudo sed -i 's/__atomic_compare_exchange/__atomic_compare_exchange_db/g' db-5.1.29/src/dbinc/atomic.h
cd db-5.1.29/build_unix/
hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=/home/crypto-data/berkeley/db5.1
hide_output sudo make -j$((`nproc`+1))
hide_output sudo make install -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r db-5.1.29.tar.gz db-5.1.29
echo -e "$GREEN => Berkeley 5.1 Completed <= ${NC}"

# Build BerkeleyDB 5.3
echo -e "\n$MAGENTA => Building Berkeley 5.3 <= ${NC}"
sudo mkdir -p $STORAGE_ROOT/berkeley/db5.3/
hide_output sudo wget 'http://anduin.linuxfromscratch.org/BLFS/bdb/db-5.3.28.tar.gz'
hide_output sudo tar -xzvf db-5.3.28.tar.gz
sudo sed -i 's/__atomic_compare_exchange/__atomic_compare_exchange_db/g' db-5.3.28/src/dbinc/atomic.h
cd db-5.3.28/build_unix/
hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=/home/crypto-data/berkeley/db5.3
hide_output sudo make -j$((`nproc`+1))
hide_output sudo make install -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r db-5.3.28.tar.gz db-5.3.28
echo -e "$GREEN => Berkeley 5.3 Completed <= ${NC}"

# Build BerkeleyDB 6.2
echo -e "\n$MAGENTA => Building Berkeley 6.2 <= ${NC}"
sudo mkdir -p $STORAGE_ROOT/berkeley/db6.2/
hide_output sudo wget 'http://download.oracle.com/berkeley-db/db-6.2.32.tar.gz'
hide_output sudo tar -xzvf db-6.2.32.tar.gz
sudo sed -i 's/__atomic_compare_exchange/__atomic_compare_exchange_db/g' db-6.2.32/src/dbinc/atomic.h
cd db-6.2.32/build_unix/
hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=/home/crypto-data/berkeley/db6.2
hide_output sudo make -j$((`nproc`+1))
hide_output sudo make install -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r db-6.2.32.tar.gz db-6.2.32
echo -e "$GREEN => Berkeley 6.2 Completed <= ${NC}"

# Build BerkeleyDB 18
echo -e "\n$MAGENTA => Building Berkeley 18 <= ${NC}"
sudo mkdir -p $STORAGE_ROOT/berkeley/db18/
hide_output sudo wget 'https://download.oracle.com/berkeley-db/db-18.1.40.tar.gz'
hide_output sudo tar -xzvf db-18.1.40.tar.gz
cd db-18.1.40/build_unix/
hide_output sudo ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=/home/crypto-data/berkeley/db18
hide_output sudo make -j$((`nproc`+1))
hide_output sudo make install -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r db-18.1.40.tar.gz db-18.1.40
echo -e "$GREEN => Berkeley 18 Completed <= ${NC}"

# Build OpenSSL 1.0.2g
echo -e "\n$MAGENTA => Building OpenSSL 1.0.2g <= ${NC}"
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
hide_output sudo wget https://www.openssl.org/source/old/1.0.2/openssl-1.0.2g.tar.gz --no-check-certificate
hide_output sudo tar -xf openssl-1.0.2g.tar.gz
cd openssl-1.0.2g
hide_output sudo ./config --prefix=$STORAGE_ROOT/openssl --openssldir=$STORAGE_ROOT/openssl shared zlib
hide_output sudo make -j$((`nproc`+1))
hide_output sudo make install -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r openssl-1.0.2g.tar.gz openssl-1.0.2g
echo -e "$GREEN => OpenSSL 1.0.2g Completed <= ${NC}"

# Build bls-signatures
echo -e "\n$MAGENTA => Building bls-signatures <= ${NC}"
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
hide_output sudo wget 'https://github.com/codablock/bls-signatures/archive/v20181101.zip'
hide_output sudo unzip v20181101.zip
cd bls-signatures-20181101
hide_output sudo cmake .
hide_output sudo make install -j$((`nproc`+1))
cd $STORAGE_ROOT/yiimp/yiimp_setup/tmp
sudo rm -r v20181101.zip bls-signatures-20181101
echo -e "$GREEN => bls-signatures Completed <= ${NC}"

# Build blocknotify.sh
echo -e "\n$YELLOW => Building blocknotify.sh <= ${NC}"
if [[ ("$wireguard" == "true") ]]; then
    source $STORAGE_ROOT/yiimp/.wireguard.conf
    echo '#####################################
    # Created by Afiniel for Yiimpool use...  #
    ###########################################
    #!/bin/bash
    blocknotify '""''"${DBInternalIP}"''""':$1 $2 $3' | sudo -E tee /usr/bin/blocknotify.sh >/dev/null 2>&1
else
    echo '#####################################
    # Created by Afiniel for Yiimpool use...  #
    ###########################################
    #!/bin/bash
    blocknotify 127.0.0.1:$1 $2 $3' | sudo -E tee /usr/bin/blocknotify.sh >/dev/null 2>&1
fi
sudo chmod +x /usr/bin/blocknotify.sh
echo -e "$GREEN => blocknotify.sh Completed <= ${NC}"

# Install daemonbuilder
echo -e "\n$MAGENTA => Installing daemonbuilder <= ${NC}"
cd $HOME/Yiimpoolv1/daemon_builder
sudo mkdir -p conf
sudo cp -r $HOME/Yiimpoolv1/daemon_builder/utils/* $STORAGE_ROOT/daemon_builder
sudo cp -r $HOME/Yiimpoolv1/daemon_builder/conf/daemonbuilder.sh /etc/
hide_output sudo cp -r $HOME/Yiimpoolv1/daemon_builder/utils/addport.sh /usr/bin/addport
sudo chmod +x $STORAGE_ROOT/daemon_builder/*
sudo chmod +x /usr/bin/addport

# Set up daemonbuilder command
echo '
#!/usr/bin/env bash
source /etc/yiimpooldonate.conf
source /etc/yiimpool.conf
source /etc/functions.sh
cd $STORAGE_ROOT/daemon_builder
bash start.sh
cd ~
' | sudo -E tee /usr/bin/daemonbuilder >/dev/null 2>&1
sudo chmod +x /usr/bin/daemonbuilder
echo -e "$GREEN => daemonbuilder Command Set Up <= ${NC}"

# Check and create conf directory
if [ ! -d "$STORAGE_ROOT/daemon_builder/conf" ]; then
  sudo mkdir -p $STORAGE_ROOT/daemon_builder/conf
fi

# Create info.sh
echo '#!/bin/sh
USERSERVER='"${whoami}"'
VERSION='"${TAG}"'

PATH_STRATUM='"${STRATUM_DIR}"'
FUNCTION_FILE='"${FUNCTIONFILE}"'

BTCDON='"${BTCDON}"'
LTCDON='"${LTCDON}"'
ETHDON='"${ETHDON}"'
DOGEDON='"${DOGEDON}"'' | sudo -E tee $STORAGE_ROOT/daemon_builder/conf/info.sh >/dev/null 2>&1
sudo chmod +x $STORAGE_ROOT/daemon_builder/conf/info.sh

cd $HOME/Yiimpoolv1/yiimp_single
