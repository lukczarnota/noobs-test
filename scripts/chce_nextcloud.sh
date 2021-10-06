#!/bin/bash
# NEXTCLOUD installation script
# Autor: Mariusz 'maniek205' Kowalski

USERNAME=admin
PASSWORD=$(head -c 100 /dev/urandom | tr -dc A-Za-z0-9 | head -c13) 

DB_USER=root
DB_PASS=$(head -c 100 /dev/urandom | tr -dc A-Za-z0-9 | head -c13) 

#Set Timezone to prevent installation interruption
ln -snf /usr/share/zoneinfo/Poland /etc/localtime && echo "Etc/UTC" > /etc/timezone


#Installing prerequisites https://docs.nextcloud.com/server/latest/admin_manual/installation/example_ubuntu.html
apt update
apt install -y apache2 mariadb-server libapache2-mod-php7.4
apt install -y php7.4-gd php7.4-mysql php7.4-curl php7.4-mbstring php7.4-intl
apt install -y php7.4-gmp php7.4-bcmath php-imagick php7.4-xml php7.4-zip

#Configuring mariaDB
/etc/init.d/mysql start
mysql -u$DB_USER -p$DB_PASS -e "CREATE USER '$USERNAME'@'localhost' IDENTIFIED BY '$PASSWORD'; 
CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci; 
GRANT ALL PRIVILEGES ON nextcloud.* TO '$USERNAME'@'localhost'; 
FLUSH PRIVILEGES;"

#Downloading nextcloud zip file
apt install -y wget tar
wget https://download.nextcloud.com/server/releases/nextcloud-22.2.0.tar.bz2
tar -xf nextcloud-22.2.0.tar.bz2
#Copy nextcloud to apache folder
rm /var/www/html/index.html
cp -r nextcloud/ /var/www/html/

#Apache config
cat > /etc/apache2/sites-available/nextcloud.conf <<EOL
Alias /nextcloud "/var/www/html/nextcloud/"

<Directory /var/www/html/nextcloud/>
  Satisfy Any
  Require all granted
  AllowOverride All
  Options FollowSymLinks MultiViews

  <IfModule mod_dav.c>
    Dav off
  </IfModule>
</Directory>
EOL

a2ensite nextcloud.conf
a2enmod rewrite
a2enmod headers
a2enmod env
a2enmod dir
a2enmod mime
a2enmod setenvif
service apache2 reload
service apache2 restart

echo "USERNAME=$USERNAME
PASSWORD=$PASSWORD
DB_USER=$DB_USER
DB_PASS=$DB_PASS"
