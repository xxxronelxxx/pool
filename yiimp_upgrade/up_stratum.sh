#####################################################
# Created by afiniel for crypto use...
#####################################################

source /etc/functions.sh
source /etc/yiimpool.conf
source $STORAGE_ROOT/yiimp/.yiimp.conf

if [[ ! -e '$STORAGE_ROOT/yiimp/yiimp_setup/yiimp' ]]; then
sudo rm -r $STORAGE_ROOT/yiimp/yiimp_setup/yiimp
hide_output sudo git clone ${YiiMPRepo} $STORAGE_ROOT/yiimp/yiimp_setup/yiimp
else
hide_output sudo git clone ${YiiMPRepo} $STORAGE_ROOT/yiimp/yiimp_setup/yiimp
fi

echo -e "$YELLOW Upgrading stratum... ${NC}"
cd $STORAGE_ROOT/yiimp/yiimp_setup/yiimp/stratum/iniparser
hide_output make -j$((`nproc`+1))

cd $STORAGE_ROOT/yiimp/yiimp_setup/yiimp/stratum
hide_output make -j$((`nproc`+1))

sudo mv stratum $STORAGE_ROOT/yiimp/site/stratum

echo "Stratum build complete..."
cd $HOME/Yiimpoolv1/yiimp_upgrade
