#!/bin/bash

WP_PATH="/var/www/html/wordpress"
WP_CONFIG_PATH="/var/www/html/wordpress/wp-config.php"


function setUpConfig() {
    #----DEBUG ENABLED----#
    sudo dd if=cfg/wp-config.php of=$WP_CONFIG_PATH
    echo -e '\n *DEBUG ENABLED*\n'
}


function checkWordpressConfig() {
    if [ -e $WP_CONFIG_PATH ]; then
        setUpConfig
    else
        echo "Theres is no file 'wp-config.php' in $WP_PATH"
        exit
    fi
}


function main() {
    checkWordpressConfig
}
main