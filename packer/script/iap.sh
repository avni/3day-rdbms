#!/bin/bash

# VM version
echo "$VM_VERSION" > /etc/iap-release

# mysql
echo "mysql-server mysql-server/root_password password root" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password root" | sudo debconf-set-selections
sudo apt-get -y install mysql-server

# misc packages
sudo apt-get -y install php5 php5-mysql php5-json php5-curl emacs24 php-elisp tree
sudo apt-get -y install firefox gnome-panel gnome-terminal

# phpmyadmin
MYSQL_ROOT_PASS="root"
PHPMYADMIN_DIR="phpmyadmin"
PHPMYADMIN_PASS="phpmyadmin"
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-user string root" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $MYSQL_ROOT_PASS" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_PASS" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_PASS" | sudo debconf-set-selections
sudo apt-get -y install phpmyadmin
sudo sed -i -r "s:(Alias /).*(/usr/share/phpmyadmin):\1$PHPMYADMIN_DIR \2:" /etc/phpmyadmin/apache.conf
sudo php5enmod mcrypt # Needs to be activated manually (that's an issue for Ubuntu 14.04)
sudo service apache2 reload

#cat <<EOF >> /etc/phpmyadmin/conf.d/iap.php
#<?php
#
#$cfg['Servers'][1]['auth_type'] = 'config';
#$cfg['Servers'][1]['user'] = 'dev';
#$cfg['Servers'][1]['password'] = 'dev';
#
#EOF

# oracle jdk
#sudo apt-get -y install python-software-properties
#sudo add-apt-repository -y ppa:webupd8team/java 
#sudo apt-get -q -y update  
#echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
#echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
#sudo apt-get -y install oracle-java7-installer 
 
# tmp dir
mkdir /usr/local/tmp
chmod 777 /usr/local/tmp

# vagrant launcher helpers
mkdir /home/$SSH_USERNAME/.local/share/applications
chown $SSH_USERNAME /home/$SSH_USERNAME/.local/share/applications
chmod 700 /home/$SSH_USERNAME/.local/share/applications

# apache
a2enmod userdir
sudo sed -i -r "s:^(\s*php_admin_flag engine Off):#\1:" /etc/apache2/mods-available/php5.conf
service apache2 restart

# make logs readable without sudo
chmod -R r+w /var/log/apache2

# mysql apparmor
cat <<EOF >> /etc/apparmor.d/local/usr.sbin.mysqld
/usr/local/tmp/ r,
/usr/local/tmp/** rwk,
EOF
service apparmor reload

# this should probably run again after user settings
updatedb
