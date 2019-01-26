#!/bin/sh

## restart hostapd service
#  ! SIGHUP does not work despite /etc/init.d/hostapd making reference to it (might need to try C++)
#  ! when using service restart, hostapd needed two restarts to be consistent but the service would fall over rather quickly
#  ! stop / stop / start does not seem to fall over the same as stop start / stop start or restart / restart
#  ! reloading hostapd conf on the fly needs further investigation

# restart hostapd
sudo service hostapd stop
sudo service hostapd stop
sudo service hostapd start
