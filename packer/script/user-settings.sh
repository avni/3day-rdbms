#!/bin/bash

# android studio
cd ~
tar xvfz /usr/local/tmp/${STUDIO_ZIP}
rm /usr/local/tmp/${STUDIO_ZIP}

sleep 20 #wait for desktop to launch; you may have to adjust this depending on build host
. /usr/local/tmp/discover_session_bus_address.sh unity
gsettings set com.canonical.Unity.Launcher favorites "['application://debian-xterm.desktop','application://firefox.desktop','application://phpmyadmin.desktop','application://jetbrains-android-studio.desktop']"
rm /usr/local/tmp/discover_session_bus_address.sh

