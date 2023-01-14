#!/bin/bash

#For installation
PHP_MODULES="php php8.1 php8.1-fmp php8.1-gd php8.1-curl php8.1-html php8.1-xml php8.1-bcmath"
ELK_GPG="https://artifacts.elastic.co/GPG-KEY-elasticsearch"
ELK_REPO="deb htpps://artifacts.elastic.co/packages/7.x/apt stable main"

#For Config
DB_MYSQL="wp_mysite"
DB_USER="wp_mysite_user"
DB_PSSWD="passwd"
NGINX_VH_PATH="/etc/nginx/sites-available/mysite"
FB_PATH="/etc/filebeat/"
FB_MODULES_PATH="/etc/filebeat/modules.d/"


function printCredentials() {
    echo -e "\n###DATA BASE CREDENTIALS###\n"
    echo -e "   Data base: $DB_MYSQL\n   DB User: $DB_USER\n   DB password: $DB_PASSWD"
    exit
}


function setUpConfig() {
    # --> Mysql
    #----DB & USER----

    sudo mysql
    create database ${DB_MYSQL};
    create user ${DB_USER} identified by "$DB_PSSWD";
    grant all privileges ${DB_MYSQL}.* to ${DB_USER};
    flush privileges;
    quit;
    
    # --> Nginx
    #----Virtual Host----
    
    sudo cp /etc/nginx/sites-available/default ${NGINX_VH_PATH}
    sudo dd if=./cfg/mysite of=${NGINX_VH_PATH}
    sudo ln -s ${NGINX_VH_PATH} /etc/nginx/sites-enabled/
    
    echo "127.0.0.1     mysite.com" | sudo tee -a /etc/hosts 
    
    nginx -s reload

    #----Services----

    sudo systemctl enable nginx.service
    sudo systemctl daemon-reload
    sudo systemctl start nginx.service

    # --> Filebeat
    #----Modules Enabled----
    
    sudo filebeat modules enable nginx
    sudo filebeat modules enable mysql

    #----Config Files---
    
    sudo dd if=./cfg/nginx.yml of=${FB_MODULES_PATH}nginx.yml
    sudo dd if=./cfg/nginx.yml of=${FB_MODULES_PATH}mysql.yml
    sudo dd if=./cfg/filebeats.yml of=${FB_PATH}filebeat.yml

    #----Services----
    sudo systemctl enable filebeat.service
    sudo systemctl daemon-reload
    sudo systemctl start filebeat.service

    # ---> NOTES
    echo -e '\n### output.elasticsearch is disabled ###'
    echo -e '### output.kibana is disabled ###'
    echo -e '### output.logstash hosts is set to:   "localhost:5044"   ###'
    echo -e '\n *** This configurations ar set in ---> filebeat.yml ***\n'
    sleep 5
}


function installPackages() {
    sudo apt update
    
    sudo apt install nginx
    sudo apt install mysql-server mysql-client
    sudo apt install ${PHP_MODULES} 
    
    wget https://wordpress.org/latest.tar.gz
    tar -xzfv latest.tar.gz
    sudo mv ./wordpress /var/www/html/

    wget -qO - ${ELK_GPG} | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
    sudo apt-get install apt-transport-https
    echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] $ELK_REPO" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
    sudo apt update && sudo apt install filebeat
}


function main() {
    installPackages
    setUpConfig
    printCredentials
}
main