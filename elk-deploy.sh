#!/bin/bash

#For Installation
ELK_GPG="https://artifacts.elastic.co/GPG-KEY-elasticsearch"
ELK_REPO="deb htpps://artifacts.elastic.co/packages/7.x/apt stable main"

#For Config
ELASTIC_CFG_PATH="/etc/elasticsreach/elasticsearch.yml"
KIB_PSSWD="kibana_admin:passwd1234"
NGINX_VH_PATH="/etc/nginx/sites-available/kibana"
LOGSTASH_FB_PATH="/etc/logstash/conf.d/"


function printCredentials() {
    echo -e "\n Credentials (user:password) "
    echo -e "\n $KIB_PSSWD <-- This is for autentication in your website 'kibana.com'"
    sleep 5
    echo -e "\nIn your local machine. You will have to edit /etc/hosts\nPaste this:"
    echo -e "IP-FROM-VM-WORDPRESS   mysite.com"
    echo -e "IP-FROM-VM-ELK kibana.com"
    exit
}


function setUpConfig() {
    # --> Elasticsearch
    #----Config----
    sed -i 's/#http.port: 9200/http.port: 9200/g'${ELASTIC_CFG_PATH}
    echo "indices.memory.index_buffer_size: 20%"| sudo tee -a ${ELASTIC_CFG_PATH}
    
    #----Service----
    sudo systemctl enable elasticsearch
    sudo systemctl daemon.reload
    sudo systemctl start elasticsearch

    # --> Kibana
    #----Service----
    sudo systemctl enable kibana
    sudo systemctl daemon.reload
    sudo systemctl start kibana
    
    # --> Nginx
    #----Credentials----
    echo "$KIB_PASSWD" | sudo tee -a /etc/nginx/htpasswd.users 

    #----Reverse Proxy----
    sudo cp /etc/nginx/sites-available/default ${NGINX_VH_PATH}
    sudo dd if=./cfg/kibana of=${NGINX_VH_PATH}
    nginx -s reload

    # --> Logstash
    #----Config----
    sudo cp ./cfg/fb_nignx-mysql-wp.conf ${LOGSTASH_FB_PATH}
    
    #----Service----
    sudo systemctl enable logstash
    sudo systemctl daemon.reload
    sudo systemctl start logstash
    
    # ---> /etc/hosts
    echo "127.0.0.1     kibana.com" | sudo tee -a /etc/hosts

    # ---> NOTES
    echo -e '\n ### INFO ### \n'
    echo -e ' All the network config is set to: "localhost".'
    echo -e ' All the logs are going to the same index in logstash. \n'
    sleep 5
}


function installPackages() {
    wget -qO - ${ELK_GPG} | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
    sudo apt-get install apt-transport-https
    echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] $ELK_REPO" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
    sudo apt update && sudo apt install elasticsearch kibana logstash nginx
}


function main() {
    installPackages
    setUpConfig
    printCredentials
}
main