#####################################################
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by afiniel for crypto use...
#####################################################

message_box "Yiimpool Stratum upgrade" \
"You have chosen to upgrade your YiiMP server(s)!
\n\nThis upgrade will only update the core stratum files while preserving your existing configuration.
\n\nIMPORTANT NOTES:
\n\n- Your existing stratum configuration files in /home/crypto-data/yiimp/site/stratum/config will NOT be modified
\n\n- This ensures your custom port and algorithm settings remain intact
\n\n- If you need configuration examples for new algorithms, please check our GitHub repository
\n\n
\n\nThe upgrade process has two parts:
\n\n1. Stratum Server Update: Updates the core stratum functionality
\n\n2. Web Server Update: Updates only the web/yaamp/core/functions/yaamp.php file
\n\nPlease ensure you run both parts in the correct order for a complete upgrade."
