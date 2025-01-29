#####################################################
# Created by afiniel for crypto use...
#####################################################

source /etc/functions.sh
source /etc/yiimpool.conf
source $STORAGE_ROOT/yiimp/.yiimp.conf

if [[ ! -e '$STORAGE_ROOT/yiimp/yiimp_setup/yiimp' ]]; then
sudo rm -r $STORAGE_ROOT/yiimp/yiimp_setup/yiimp
sudo git clone ${YiiMPRepo} $STORAGE_ROOT/yiimp/yiimp_setup/yiimp
else
sudo git clone ${YiiMPRepo} $STORAGE_ROOT/yiimp/yiimp_setup/yiimp
fi

echo -e "$CYAN Updating Stratum... ${NC}"

# Compil Stratum
cd /home/crypto-data/yiimp/yiimp_setup/yiimp/stratum

sudo git submodule init && sudo git submodule update
sudo make -C algos
sudo make -C sha3
sudo make -C iniparser

cd /home/crypto-data/yiimp/yiimp_setup/yiimp/stratum
sudo make -j$((`nproc`+1))

sudo mv stratum $STORAGE_ROOT/yiimp/site/stratum

cd $STORAGE_ROOT/yiimp/yiimp_setup/yiimp/web/yaamp/core/functions/
cp -r yaamp.php $STORAGE_ROOT/yiimp/site/web/yaamp/core/functions

echo -e "$YELLOW Stratum build$GREEN complete... ${NC}"
cd $HOME/Yiimpoolv1/yiimp_upgrade
