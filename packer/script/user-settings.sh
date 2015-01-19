#!/bin/bash

sleep 20 #wait for desktop to launch; you may have to adjust this depending on build host
. /usr/local/tmp/discover_session_bus_address.sh unity
gsettings set com.canonical.Unity.Launcher favorites "['application://debian-xterm.desktop','application://firefox-iap.desktop','application://phpmyadmin.desktop','application://nautilus.desktop','application://emacs24.desktop']"
gsettings set com.canonical.Unity integrated-menus true

rm /usr/local/tmp/discover_session_bus_address.sh

cd ~/sql; mysql -u root -proot < _load.sql

# remove data import file loaded into mysql in previous step
rm -f $DATA_FILE
