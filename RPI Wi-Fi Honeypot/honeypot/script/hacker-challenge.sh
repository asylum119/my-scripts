#!/bin/sh

# Exit trap - boot with USB plugged into RPI to regain terminal access
if sudo fdisk -l | grep /dev/sda1; then
  exit 0
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
#  Project: Dynamic Wi-Fi Honeypot 4RPI3
#          - Wi-Fi Hacking Challenge Script
#
#  Version: Proof Of Concept
#  Author: Brett Peters, 2017
#  Contact: asylum119@hotmail.com
#
#  DESCRIPTION:
#  Use the RPI3's onboard Wi-Fi interface to broadcast a
#  single Dynamic Wi-Fi AP, then update the SSID with a
#  random response upon each connection attempt.
#
#  This script dynamically updates the broadcast SSID with
#  a predefined response, at random, when a connection attempt
#  is made on the default SSID. The SSID response falls back to
#  the default SSID after the broadcast response time is reached.
#
#  This particular script is a hacking challenge to detect threat
#  devices pen testing Wi-Fi, allowing router admins to block threat
#  MAC addresses, or simply just an SSID to have some fun with.
#
#  MAC ADDRESS LOG:
#  * honeypot/log/master-mac - Master MAC Log used by all honeypot scripts
#
#  NOTES:
#  /var/log/syslog gets cleared out by this script to
#  combat the RPI not having onboard time to use up to date
#  time stamps, something to consider if wanting to implement
#  on a NON single project RPI or use on a different machine.
#
#  REQUIREMENTS:
#  * RPI2
#  * GNU/Linux
#  * HostAPD
#  * Dnsmasq
#  * Edit conf files (see readme file)
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Script Settings - SSID
default_ssid="Can't Hack This"
welcome_ssid="Welcome! Rename The SSID To Win"
broadcast_time="120"
public_broadcast="True"
ssid_pass="!@Qhg@mk:aaaaaaaaa11111111111a11aa1!::::"

# System reboot settings
reboot_system="True"
reboot_on_loop="20000"

# Script Settings - ADVANCED
master_mac="/etc/honeypot/log/master-mac"
syslog="/var/log/syslog"
hostapd_conf="/etc/honeypot/config/hostapd.conf"
hostapd_restart="/etc/honeypot/command/./restart.sh"
clear_syslog="/etc/honeypot/command/./clear.sh"
system_reboot="/etc/honeypot/command/./reboot.sh"
honeypot="/etc/honeypot"
script_dir="/etc/honeypot/script"

# Start the script
PROMPT_COMMAND=
echo "\033]0;Wi-Fi Honeypot - Hacker Challenge\a"
clear

# Set broadcast options
if [ $public_broadcast = "True" ]; then
  broadcast_option='0'
else
  broadcast_option='1'
fi

# Initial broadcast settings
random_bssid='00:20:91:00:00:00'
channel_number='11'

# Check for required packages
if [ ! -d '/etc/hostapd' ] || [ ! -d '/etc/dnsmasq.d' ]; then
  echo "* NOTE: Please check that \"hostapd\" and \"dnsmasq\" are installed"
  echo "* Script is unable to run as expected"
  sleep 3
  echo "* goodbye"
  exit 1
elif [ ! -d $honeypot ]; then
  echo "* NOTE: Please check that you copied the honeypot files correctly"
  echo "* Script is unable to run as expected"
  sleep 3
  echo "* goodbye"
  exit 1
fi

# Prepare the environment
sudo sh $clear_syslog
if [ ! -f $master_mac ]; then
  touch $master_mac
fi
if [ ! -f $hostapd_conf ]; then
  touch $hostapd_conf
fi
if [ -d $honeypot ]; then
  sudo chmod 777 -R $honeypot
fi

# Update HostAPD configuration
cat <<EOF > $hostapd_conf
interface=wlan0
ssid=$default_ssid
bssid=$random_bssid
ignore_broadcast_ssid=$broadcast_option
channel=$channel_number
auth_algs=1
wpa=2
wpa_passphrase=$ssid_pass
wpa_key_mgmt=WPA-PSK
wpa_group_rekey=86400
ieee80211n=1
EOF

# Restart HostAPD if necessary
if sudo service hostapd | grep dead; then
  sudo sh $hostapd_restart
fi
if sudo service hostapd status | grep exited; then
  sudo service hostapd force-reload
fi

# Display startup information
echo '	 Wi-Fi Honeypot Is Loading...'
if ! sudo fdisk -l | grep dev/sda1; then
  echo '	 Insert USB and reboot to regain terminal access'
fi
sudo sh $hostapd_restart
clear
echo "Wi-Fi Honeypot is broadcasting \"${default_ssid}\""
echo 'Scanning for connection attempts...'
if grep -q ":" $master_mac; then
  echo '- - - - - - - -\nLogged Devices\n- - - - - - - -'
  cat $master_mac
  echo ''
else
  echo '- - - - - - - -\nLogged Devices\n- - - - - - - -\n\nNo devices are logged'
fi

# Infinite loop
while :
do
  sleep 4
  loop_pass=$((loop_pass+1))

  # Check if user wants a reboot
  if [ $reboot_system = "True" ] && grep -q "$default_ssid" $hostapd_conf; then
    if [ "$loop_pass" -gt "$reboot_on_loop" ]; then
      sudo sh $system_reboot
    fi
  fi
