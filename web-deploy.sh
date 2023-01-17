#!/bin/bash

#For installation
PHP_MODULES='php php8.1 php8.1-fpm php8.1-gd php8.1-curl php8.1-http php8.1-xml php8.1-bcmath php8.1-mysql'
ELK_GPG="https://artifacts.elastic.co/GPG-KEY-elasticsearch"
ELK_REPO="deb https://artifacts.elastic.co/packages/7.x/apt stable main"

#For Config
DB_MYSQL="wp_mysite"
DB_USER="wp_mysite_user"
DB_PSSWD="passwd"
NGINX_VH_PATH="/etc/nginx/sites-available/mysite"
FB_CFG_PATH="/etc/filebeat/filebeat.yml"
FB_MODULES_PATH="/etc/filebeat/modules.d"
WP_PATH="/var/www/html/wordpress"


function printCredentials() {
    echo -e "\n ###DATA BASE CREDENTIALS###\n"
    echo -e "   Data base:	$DB_MYSQL\n   DB User:	$DB_USER\n   DB password:	$DB_PSSWD\n"
}


function setUpConfig() { 
    echo -e '\n# --> Nginx'
    echo '#----Virtual Host----'
  
    sudo cp /etc/nginx/sites-available/default $NGINX_VH_PATH
    sudo dd if=cfg/mysite of=$NGINX_VH_PATH
    sudo ln -s $NGINX_VH_PATH /etc/nginx/sites-enabled/ 2>/dev/null

    sudo find /var/log/nginx/ -type d -exec chmod 755 {} \;
    sudo find /var/log/nginx/ -type f -exec chmod 644 {} \;

    sudo chown www-data:www-data -R /etc/nginx
    sudo chown www-data:www-data -R /var/log/nginx
    sudo chown www-data:www-data -R /var/www/html
    
    grep 'mysite.com' /etc/hosts
    if [ $? -ne 0 ]; then
        echo "127.0.0.1 mysite.com" | sudo tee -a /etc/hosts 
    fi 
    
    echo -e '\n#----Firewall----'
    
    sudo ufw allow 'Nginx Full'
    
    echo -e '\n#----Services----'

    sudo nginx -s reload
    sudo systemctl enable nginx.service
    sudo systemctl daemon-reload
    sudo systemctl reload nginx.service

    echo -e '\n# --> Filebeat'
    echo -e '#----Modules Enabled----'
    
    sudo filebeat modules enable nginx
    sudo filebeat modules enable mysql

    echo -e '\n#----Config Files----'
    

    sudo dd if=cfg/nginx.yml of=$FB_MODULES_PATH/nginx.yml
    sudo dd if=cfg/mysql.yml of=$FB_MODULES_PATH/mysql.yml
    sudo dd if=cfg/filebeat.yml of=$FB_CFG_PATH/filebeat.yml

    echo -e '\n#----Services----'
    sudo systemctl enable filebeat
    sudo systemctl daemon-reload
    sudo systemctl start filebeat
    sudo systemctl restart filebeat

    
    echo -e '\n # --> INFO'
    echo ' # output.elasticsearch is disabled'
    echo ' # output.kibana is disabled'
    echo ' # output.logstash hosts is set to:  ["localhost:5044"]'
    echo ' # NOTE: You have to manually change this setting for Filebeat to send logs to Logstash.'
    echo -e '\n *** This configurations are set in ---> filebeat.yml ***\n'
}


function installPackages() {
    sudo apt-get update

    sudo apt-get install -y wget nginx mysql-server mysql-client
    sudo apt-get install -y $PHP_MODULES
  
    if [ ! -e $WP_PATH ]; then
        wget https://wordpress.org/latest.tar.gz
        tar xzfv latest.tar.gz 1>/dev/null
        sudo mv wordpress/ $WP_PATH
    else
        echo "[info]: Wordpress is in $WP_PATH"
    fi

    wget -qO - $ELK_GPG | sudo apt-key add
    echo $ELK_REPO | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
    sudo apt-get update && sudo apt-get install -y filebeat
}


function main() {
    installPackages
    setUpConfig
    printCredentials
}
main

# --> Mysql
#----DB & USER----

sudo mysql <<EOFMYSQL
create database IF NOT EXISTS $DB_MYSQL;
create user IF NOT EXISTS $DB_USER identified by "$DB_PSSWD";
grant all privileges on $DB_MYSQL.* to $DB_USER;
flush privileges;
quit
EOFMYSQL
exit