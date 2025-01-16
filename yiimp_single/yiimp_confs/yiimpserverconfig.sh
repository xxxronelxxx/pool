#!/usr/bin/env bash

#####################################################
# Created by Afiniel for Yiimpool use...
#####################################################

source /etc/functions.sh
source /etc/yiimpool.conf
source $STORAGE_ROOT/yiimp/.yiimp.conf
source $HOME/Yiimpoolv1/yiimp_single/.wireguard.install.cnf

if [[ ("$wireguard" == "false") ]]; then

<?php

ini_set('date.timezone', 'UTC');

define('YAAMP_LOGS', '${STORAGE_ROOT}/yiimp/site/log');
define('YAAMP_HTDOCS', '${STORAGE_ROOT}/yiimp/site/web');
define('YAAMP_BIN', '/bin');

define('YAAMP_DBHOST', 'localhost');
define('YAAMP_DBNAME', '${YiiMPDBName}');
define('YAAMP_DBUSER', '${YiiMPPanelName}');
define('YAAMP_DBPASSWORD', '${PanelUserDBPassword}');

define('YAAMP_SITE_URL', '${DomainName}');
define('YAAMP_STRATUM_URL', '${StratumURL}'); // change if your stratum server is on a different host
define('YAAMP_SITE_NAME', '${DomainName}');

define('YAAMP_PRODUCTION', true);

define('YIIMP_PUBLIC_EXPLORER', true);
define('YIIMP_PUBLIC_BENCHMARK', false);

define('YAAMP_RENTAL', true);
define('YAAMP_LIMIT_ESTIMATE', false);

define('YAAMP_FEES_SOLO', 1);
define('YAAMP_FEES_MINING', 0.5);
define('YAAMP_FEES_EXCHANGE', 2);
define('YAAMP_FEES_RENTING', 2);
define('YAAMP_TXFEE_RENTING_WD', 0.002);
define('YAAMP_PAYMENTS_FREQ', 3*60*60);
define('YAAMP_PAYMENTS_MINI', 0.001);

define('YAAMP_ALLOW_EXCHANGE', false);
define('YIIMP_FIAT_ALTERNATIVE', 'EUR'); // USD is main

define('YAAMP_USE_NICEHASH_API', false);

define('YAAMP_BTCADDRESS', '1Auhps1mHZQpoX4mCcVL8odU81VakZQ6dR');

define('YIIMP_ADMIN_LOGIN', false);
define('YAAMP_ADMIN_EMAIL', '${SupportEmail}');
define('YAAMP_ADMIN_USER', '${AdminUser}');
define('YAAMP_ADMIN_PASS', '${AdminPassword}');
define('YAAMP_ADMIN_IP', '${PublicIP}'); // samples: "80.236.118.26,90.234.221.11" or "10.0.0.1/8"
define('YAAMP_ADMIN_WEBCONSOLE', true);
define('YAAMP_CREATE_NEW_COINS', true);
define('YAAMP_NOTIFY_NEW_COINS', false);
define('YAAMP_DEFAULT_ALGO', 'x11');

/* Github access token used to scan coin repos for new releases */
/* define('GITHUB_ACCESSTOKEN', '<username>:<api-secret>'); */

/* mail server access data to send mails using external mailserver */
/* define('SMTP_HOST', 'mail.example.com'); */
/* define('SMTP_PORT', 25); */
/* define('SMTP_USEAUTH', true); */
/* define('SMTP_USERNAME', 'mailuser'); */
/* define('SMTP_PASSWORD', 'mailpassword'); */
/* define('SMTP_DEFAULT_FROM', 'mailuser@example.com'); */
/* define('SMTP_DEFAULT_HELO', 'mypool-server.example.com'); */

define('YAAMP_USE_NGINX', false);

/* Sample config file to put in /etc/yiimp/keys.php */

define('YIIMP_MYSQLDUMP_USER', 'root');
define('YIIMP_MYSQLDUMP_PASS', '<my_mysql_password>');

/* 
 * Exchange access keys
 * for public fronted use separate container instance and leave keys unconfigured
 *
 * access tokens required to create/cancel orders and access your balances/deposit addresses
 */
define('EXCH_ALTMARKETS_KEY', '');

define('EXCH_BINANCE_KEY', '');
define('EXCH_BINANCE_SECRET', '');

define('EXCH_CEXIO_SECRET', '');

define('EXCH_EXBITRON_KEY', '');

define('EXCH_HITBTC_SECRET', '');
define('EXCH_HITBTC_KEY','');

define('EXCH_KRAKEN_KEY', '');
define('EXCH_KRAKEN_SECRET','');

define('EXCH_KUCOIN_SECRET', '');

define('EXCH_POLONIEX_KEY', '');
define('EXCH_POLONIEX_SECRET', '');

define('EXCH_SAFETRADE_KEY', '');
define('EXCH_SAFETRADE_SECRET', '');

define('EXCH_TRADEOGRE_SECRET', '');

define('EXCH_YOBIT_KEY', '');
define('EXCH_YOBIT_SECRET', '');

define('EXCH_XEGGEX_KEY', '');
define('EXCH_XEGGEX_SECRET', '');

// Automatic withdraw to Yaamp btc wallet if btc balance > 0.3
define('EXCH_AUTO_WITHDRAW', 0.3);

// nicehash keys deposit account & amount to deposit at a time
define('NICEHASH_API_KEY','521c254d-8cc7-4319-83d2-ac6c604b5b49');
define('NICEHASH_API_ID','9205');
define('NICEHASH_DEPOSIT','3J9tapPoFCtouAZH7Th8HAPsD8aoykEHzk');
define('NICEHASH_DEPOSIT_AMOUNT','0.01');


$cold_wallet_table = array(
	'1C23KmLeCaQSLLyKVykHEUse1R7jRDv9j9' => 0.10,
);

// Sample fixed pool fees
$configFixedPoolFees = array(
        'zr5' => 2.0,
        'scrypt' => 20.0,
        'sha256' => 5.0,
);

// Sample fixed pool fees solo
$configFixedPoolFeesSolo = array(
		'zr5' => 2.0,
        'scrypt' => 2.0,
        'sha256' => 5.0,
);

// Sample custom stratum ports
$configCustomPorts = array(
//	'x11' => 7000,
);

// mBTC Coefs per algo (default is 1.0)
$configAlgoNormCoef = array(
//	'x11' => 5.0,
);

' | sudo -E tee $STORAGE_ROOT/yiimp/site/configuration/serverconfig.php >/dev/null 2>&1

else

	echo '<?php
ini_set('"'"'date.timezone'"'"', '"'"'UTC'"'"');
define('"'"'YAAMP_LOGS'"'"', '"'"''"${STORAGE_ROOT}/yiimp/site/log"''"'"');
define('"'"'YAAMP_HTDOCS'"'"', '"'"''"${STORAGE_ROOT}/yiimp/site/web"''"'"');
define('"'"'YAAMP_BIN'"'"', '"'"'/bin'"'"');
define('"'"'YAAMP_DBHOST'"'"', '"'"''"${DBInternalIP}"''"'"');
define('"'"'YAAMP_DBNAME'"'"', '"'"''"${YiiMPDBName}"''"'"');
define('"'"'YAAMP_DBUSER'"'"', '"'"''"${YiiMPPanelName}"''"'"');
define('"'"'YAAMP_DBPASSWORD'"'"', '"'"''"${PanelUserDBPassword}"''"'"');
define('"'"'YAAMP_PRODUCTION'"'"', true);
define('"'"'YAAMP_RENTAL'"'"', false); // For rental services
define('"'"'YAAMP_LIMIT_ESTIMATE'"'"', false);
define('"'"'MINING_FEES_SOLO'"'"', 1.5);  // Set Pool Fee (solo)
define('"'"'YAAMP_FEES_MINING'"'"', 0.5); // Set Pool Fee (non solo)
define('"'"'YAAMP_FEES_EXCHANGE'"'"', 2); // Set Exchange fee
define('"'"'YAAMP_FEES_RENTING'"'"', 2); //  Set Renting fee (If renting is enabled)
define('"'"'YAAMP_TXFEE_RENTING_WD'"'"', 0.002);
define('"'"'YAAMP_PAYMENTS_FREQ'"'"', 1*60*60); // Set how often the pool will do payouts
define('"'"'YAAMP_PAYMENTS_MINI'"'"', 0.001); // Set minimum payout amount
define('"'"'YAAMP_ALLOW_EXCHANGE'"'"', false); // Allow users to exchange coins
define('"'"'YIIMP_PUBLIC_EXPLORER'"'"', false); // Allow users to see the block explorer
define('"'"'YIIMP_PUBLIC_BENCHMARK'"'"', false); // Allow users to see the benchmark page
define('"'"'YIIMP_FIAT_ALTERNATIVE'"'"', '"'"'USD'"'"'); // USD is main
define('"'"'YAAMP_USE_NICEHASH_API'"'"', false);
define('"'"'YAAMP_BTCADDRESS'"'"', '"'"'bc1qpnxtg3dvtglrvfllfk3gslt6h5zffkf069nh8r'"'"');
define('"'"'YAAMP_SITE_URL'"'"', '"'"''"${DomainName}"''"'"');
define('"'"'YAAMP_STRATUM_URL'"'"', '"'"''"${StratumURL}"''"'"'); // change if your stratum server is on a different host
define('"'"'YAAMP_SITE_NAME'"'"', '"'"''"${DomainName}"''"'"');
define('"'"'YAAMP_ADMIN_EMAIL'"'"', '"'"''"${SupportEmail}"''"'"');
define('"'"'YAAMP_ADMIN_IP'"'"', '"'"''"${PublicIP}"''"'"'); // samples: "80.236.118.26,90.234.221.11" or "10.0.0.1/8"
define('"'"'YAAMP_ADMIN_WEBCONSOLE'"'"', true);
define('"'"'YAAMP_CREATE_NEW_COINS'"'"', false);
define('"'"'YAAMP_NOTIFY_NEW_COINS'"'"', false);
define('"'"'YAAMP_DEFAULT_ALGO'"'"', '"'"'x11'"'"');
define('"'"'YAAMP_USE_NGINX'"'"', true);

// Exchange public keys (private keys are in a separate config file)

// Automatic withdraw to Yaamp btc wallet if btc balance > 0.3
define('"'"'EXCH_AUTO_WITHDRAW'"'"', 0.3);

// nicehash keys deposit account & amount to deposit at a time
define('"'"'NICEHASH_API_KEY'"'"','"'"'521c254d-8cc7-4319-83d2-ac6c604b5b49'"'"');
define('"'"'NICEHASH_API_ID'"'"','"'"'9205'"'"');
define('"'"'NICEHASH_DEPOSIT'"'"','"'"'3J9tapPoFCtouAZH7Th8HAPsD8aoykEHzk'"'"');
define('"'"'NICEHASH_DEPOSIT_AMOUNT'"'"','"'"'0.01'"'"');

$cold_wallet_table = array(
'"'"'bc1qpnxtg3dvtglrvfllfk3gslt6h5zffkf069nh8r'"'"' => 0.10,
);

// Sample fixed pool fees
$configFixedPoolFees = array(
'"'"'zr5'"'"' => 2.0,
'"'"'scrypt'"'"' => 20.0,
'"'"'sha256'"'"' => 5.0,
);
// Sample fixed pool fees solo , With 1.5 default set.
$configFixedPoolFeesSolo = array(
'"'"'zr5'"'"' => 1.5,
'"'"'scrypt'"'"' => 1.5,
'"'"'sha256'"'"' => 1.5,
);

// Sample custom stratum ports
$configCustomPorts = array(
// '"'"'x11'"'"' => 7000,
);

// mBTC Coefs per algo (default is 1.0)
$configAlgoNormCoef = array(
// '"'"'x11'"'"' => 5.0,
);' | sudo -E tee $STORAGE_ROOT/yiimp/site/configuration/serverconfig.php >/dev/null 2>&1
fi
cd $HOME/Yiimpoolv1/yiimp_single
