#!/bin/bash

# mysql
echo "mysql-server mysql-server/root_password password root" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password root" | sudo debconf-set-selections
sudo apt-get -y install mysql-server

# misc packages
sudo apt-get -y install php5 php5-mysql php5-json php5-curl emacs24

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

# oracle jdk

sudo apt-get -y install python-software-properties
sudo add-apt-repository -y ppa:webupd8team/java 
sudo apt-get -q -y update  
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get -y install oracle-java7-installer 
 
# android studio
#TODO: copy from host instead of url pull 
#cd ~
#studio=android-studio-ide-135.1641136-linux.zip
#wget http://path/to/$studio 
#unzip $studio
#rm $studio

