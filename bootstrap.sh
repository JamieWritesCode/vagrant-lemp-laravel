#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='password'
DATABASE='data'

# create public folder
sudo mkdir "/var/www/html/public"

# add repo for php7
sudo add-apt-repository ppa:ondrej/php

#add repo for MariaDB
sudo apt-get install software-properties-common
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
sudo add-apt-repository 'deb [arch=amd64,i386] http://mariadb.mirror.digitalpacific.com.au/repo/10.1/ubuntu trusty main'

# update / upgrade
sudo apt-get update
sudo apt-get -y upgrade

# install nginx and php
sudo apt-get install -y nginx php7.0 php7.0-fpm php-zip php-xml php-mbstring

# install mysql and give password to installer
sudo debconf-set-selections <<< "maria-db-10.1 mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "maria-db-10.1 mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install mariadb-server
sudo apt-get install php7.0-mysql
sudo mysql -uroot -p${PASSWORD} -e"CREATE DATABASE ${DATABASE};"

sudo rm /etc/nginx/sites-available/default
sudo touch /etc/nginx/sites-available/default

sudo cat >> /etc/nginx/sites-available/default <<'EOF'
server {
    listen       80;
    server_name  localhost;

    root  /var/www/html/public;
    index index.php;

    location / {
    try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
    try_files $uri =404;
    include fastcgi_params;
    fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    }
}
EOF

# add php info
sudo touch /var/www/html/public/info.php
sudo cat >> /var/www/html/public/info.php <<'EOF'
<?php phpinfo(); ?>
EOF

# restart nginx
service nginx restart
sudo service php7.0-fpm restart

# install git
sudo apt-get -y install git

# install Composer
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# add Composer vendor bin directory to PATH
sudo echo 'PATH=$PATH:/home/vagrant/.config/composer/vendor/bin' >> /home/vagrant/.bashrc