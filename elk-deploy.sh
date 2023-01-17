#!/bin/bash

#For Installation
ELK_GPG="https://artifacts.elastic.co/GPG-KEY-elasticsearch"
ELK_REPO="deb https://artifacts.elastic.co/packages/7.x/apt stable main"


#For Config
ELASTIC_CFG_PATH="/etc/elasticsearch/elasticsearch.yml"
KIB_PSSWD="kibana_admin:passwd1"
NGINX_VH_PATH="/etc/nginx/sites-available/kibana"
LOGSTASH_FB_PATH="/etc/logstash/conf.d/fb_logstash.conf"
KIB_CFG_PATH="/etc/kibana/kibana.yml"


function printCredentials() {
    echo -e " In your local machine. You will have to edit /etc/hosts\n Replace the IPs and paste them:\n"
    echo " IP-FROM-VM-WORDPRESS mysite.com"
    echo " IP-FROM-VM-ELK kibana.com"
    sleep 3
    echo -e "\n *Credentials (user:password)*"
    echo -e " $KIB_PSSWD <-- This is for autentication in your website 'kibana.com'\n"
    exit
}


function setUpConfig() {
    echo -e '\n# --> Elasticsearch'
    echo '#----Config----'
    
    sudo sed -i 's/#http.port: 9200/http.port: 9200/g'$ELASTIC_CFG_PATH 2>/dev/null
    sudo grep 'indices.memory.index_buffer_size: 20%' $ELASTIC_CFG_PATH 2>/dev/null
    
    if [ $? -ne 0 ]; then
        echo "indices.memory.index_buffer_size: 20%"| sudo tee -a $ELASTIC_CFG_PATH
    fi

    echo -e '\n#----Service----'
    
    sudo systemctl enable elasticsearch
    sudo systemctl daemon-reload
    sudo systemctl start elasticsearch

    echo -e '\n# --> Kibana'
    echo '#----Config files----'
    sudo sed -i 's/#server.host:"localhost"/server.host:"localhost"/g' $KIB_CFG_PATH 2>/dev/null
    sudo sed -i 's/#server.port:5601/server.port:5601/g' $KIB_CFG_PATH 2>/dev/null
    echo 'Setting server.host to: "localhost" ...'
    echo 'Setting server.port to: 5601 ...'

    echo -e '\n#----Service----'
    
    sudo systemctl enable kibana
    sudo systemctl daemon-reload
    sudo systemctl start kibana
    
    echo -e '\n# --> Nginx'
    echo -e '#----Credentials----'

    grep "kibana_admin" /etc/nginx/htpasswd.users
    if [ $? -ne 0 ]; then
        echo "kibana_admin:`openssl passwd passwd1`"|sudo tee /etc/nginx/htpasswd.users
    fi

    echo -e '\n#----Reverse Proxy----'
    
    sudo cp /etc/nginx/sites-available/default $NGINX_VH_PATH
    sudo dd if=cfg/kibana of=$NGINX_VH_PATH
    sudo ln -s $NGINX_VH_PATH /etc/nginx/sites-enabled/ 2>/dev/null

    sudo find /var/log/nginx/ -type d -exec chmod 755 {} \;
    sudo find /etc/nginx/ -type d -exec chmod 755 {} \;
    sudo find /var/log/nginx/ -type f -exec chmod 644 {} \;
    sudo find /etc/nginx/ -type f -exec chmod 644 {} \;

    sudo chown www-data:www-data -R /etc/nginx
    sudo chown www-data:www-data -R /var/log/nginx

    grep 'kibana.com' /etc/hosts
    if [ $? -ne 0 ]; then
        echo "127.0.0.1     kibana.com" | sudo tee -a /etc/hosts
    fi

    echo -e '\n#----Firewall----'
    
    sudo ufw allow 'Nginx Full'

    echo -e '\n#----Service----'
    
    sudo nginx -s reload
    sudo systemctl enable nginx
    sudo systemctl daemon-reload
    sudo systemctl restart nginx

    echo -e '\n# --> Logstash'
    echo '#----Config----'
    echo 'Setting .conf file /etc/logstash/conf.d/fb_logstash.conf'
    sudo cp cfg/fb_logstash.conf $LOGSTASH_FB_PATH
    
    echo -e '\n#----Service----'
    
    sudo systemctl enable logstash
    sudo systemctl daemon-reload
    sudo systemctl start logstash
    sudo systemctl restart logstash
    
    echo -e '\n # --> INFO'
    echo -e '\n All the network config is set to: "localhost".'
    echo -e ' All the logs are going to the same index in logstash.\n'
    sleep 3
}


function installPackages() {
    sudo apt-get install -y wget apt-transport-https
    wget -qO - $ELK_GPG | sudo apt-key add
    echo $ELK_REPO | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
    sudo apt update && sudo apt-get install -y elasticsearch kibana logstash nginx
}


function main() {
    installPackages
    setUpConfig
    printCredentials
}
main