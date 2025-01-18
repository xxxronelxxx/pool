#!/usr/bin/env bash

#####################################################
# Created by afiniel for crypto use...
#####################################################

source /etc/yiimpoolversion.conf
source /etc/functions.sh
source /etc/yiimpool.conf
source "$STORAGE_ROOT/yiimp/.yiimp.conf"

# Install phpMyAdmin
echo -e "$CYAN Installing phpMyAdmin... $COL_RESET"
apt_install phpmyadmin


# Create symbolic link for phpMyAdmin
echo -e "$CYAN Creating symbolic link for phpMyAdmin... $COL_RESET"
if [ ! -f /usr/share/nginx/html/phpmyadmin ]; then
    ln -s /usr/share/phpmyadmin /usr/share/nginx/html/phpmyadmin
fi

# Set proper permissions
echo -e "$CYAN Setting proper permissions... $COL_RESET"
chown -R www-data:www-data /usr/share/phpmyadmin
chmod -R 755 /usr/share/phpmyadmin

# Verify PHP-FPM socket exists
echo -e "$CYAN Verifying PHP-FPM socket... $COL_RESET"
PHP_VERSION=$(php -r "echo PHP_MAJOR_VERSION.'.'.PHP_MINOR_VERSION;")
if [ ! -S /var/run/php/php${PHP_VERSION}-fpm.sock ]; then
    echo -e "$RED PHP-FPM socket not found. Please check your PHP installation! $COL_RESET"
    exit 1
fi

# Create phpMyAdmin configuration directory if it doesn't exist
if [ ! -d /etc/phpmyadmin ]; then
    mkdir -p /etc/phpmyadmin
fi

# Create phpMyAdmin temp directory
if [ ! -d /var/lib/phpmyadmin/tmp ]; then
    mkdir -p /var/lib/phpmyadmin/tmp
fi

# Set proper permissions for temp directory
chown -R www-data:www-data /var/lib/phpmyadmin
chmod 755 /var/lib/phpmyadmin/tmp

# Restart PHP-FPM and NGINX
echo -e "$CYAN Restarting PHP-FPM and NGINX... $COL_RESET"
restart_service php${PHP_VERSION}-fpm
restart_service nginx

# Final message
echo
echo -e "$GREEN phpMyAdmin installation completed! $COL_RESET"
echo -e "$YELLOW You can now access phpMyAdmin at: https://${DomainName}/phpmyadmin $COL_RESET"
echo
echo -e "$RED Please ensure you have set up a secure MySQL root password! $COL_RESET"
echo

cd $HOME/yiimpool/yiimp_single
