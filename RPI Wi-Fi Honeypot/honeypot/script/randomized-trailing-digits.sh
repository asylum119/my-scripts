#!/bin/sh
# exit trap - boot with USB to regain terminal
if sudo fdisk -l | grep /dev/sda1; then
exit 0
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
#  Project:      Dynamic Wi-Fi Honeypot 4RPI3
#                 -  Randomized SSID Trailing Digits Theme
#
#  Version:      Proof Of Concept
#  Author:       Brett Peters, 2017
#  Contact:      asylum119@hotmail.com
#
#
#  DESCRIPTION
#
#  Use the RPI3s onboard Wi-Fi interface to broadcast a
#  single Dynamic Wi-Fi AP, then update the SSID with
#  randomized trailing digits upon each connection attempt
#
#  This script dynamically updates the broadcast SSID with
#  randomized trailing digits each time a connection attempt
#  is made, there is no default SSID for a broadcast fallback
#  as this randomization is designed to be unpredictable.
#
#
#  MAC ADDRESS LOG
#
#  * honeypot/log/master-mac    <-- Master MAC Log used by all honeypot scripts
#
#
#  NOTES
#
#  /var/log/syslog gets cleared out by this script to
#  combat the RPI not having onboard time to use up to date
#  time stamps, something to consider if wanting to implement
#  on a NON single project RPI or use on a different machine
#
#
#  REQUIREMENTS
#
#  * RPI2
#  * GNU/Linux
#  * HostAPD
#  * Dnsmasq
#  * Edit conf files (see readme file)
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -






# - - - - - - - - - - - - -
# Script Settings - SSID
# - - - - - - - - - - - - -


#
# Default SSID Name
#
# ! Some math on your part may be needed as SSID broadcasts
# have a max character count of 31 characters, this script
# adds +1 for the underscore or blank space and +digit-length

  default_ssid="SMART HUB: Wi-Fi Switch"



  #
  # Trailing Underscore
  #
  # Use 'True' or 'False' depending if you want an underscore digit separator
  # Example (True):  SSID Name_178 | Example (False): SSID Name 178
  #

    underscore='True'



  #
  # Random Digits
  #
  # set how many random numbers to generate
  # ! SSID needs to be 31 characters or less, using 5 digits here means 5 (digits) + 1 (underscore or a space instead of underscore) + Default SSID character length

    digit_length='7'




#
# Hidden Or Public Broadcast - (global option affecting ALL broadcasts)
#
# ! change to "False" if you want the honeypot to mot publicly broadcast the SSIDs (make it a hidden network)
#

  # Broadcast view state
    public_broadcast="True"




#
#  Access Point Passphrase
#

  # Wi-Fi Password
    ssid_pass="!@Qhg@mk:aaaaaaaaa11111111111a11aa1!::::"




#
#  System Reboot
#
# ! change to "False" if you do never want the system to reboot
#

  # reboot the system
    reboot_system="True"

    # reboot after this many script passes
    # ! a single script path takes approximately 4 sec
      reboot_on_loop="20000"




# - - - - - - - - - - - - - -
# Script Settings - ADVANCED
# - - - - - - - - - - - - - -



# Log file (detected mac addresses)
master_mac="/etc/honeypot/log/master-mac"  # Master MAC Log used by all honeypot scripts

# System log
# ! file gets cleared by script
syslog="/var/log/syslog"

# Configuration file
# ! "/etc/default/hostapd" needs to be updated to point here
hostapd_conf="/etc/honeypot/config/hostapd.conf"

# Script paths
hostapd_restart="/etc/honeypot/command/./restart.sh"    # ! TODO: send SIGHUP to HostAPD conf
clear_syslog="/etc/honeypot/command/./clear.sh"         # ! contains hard coded path to /var/log/syslog
system_reboot="/etc/honeypot/command/./reboot.sh"

# Script directory
honeypot="/etc/honeypot"
script_dir="/etc/honeypot/script"




# - S - T - A - R - T - - T - H - E - - S - C - R - I - P - T - - >


# Unset the terminal title then create a custom one
PROMPT_COMMAND=
echo "\033]0;Wi-Fi Honeypot - Randomized Trailing Digits\a"
clear

# Script path
script_path__comment="#see  ${script_dir}/$0"

# Public broadcast option
if [ $public_broadcast = "True" ]; then
  broadcast_option='0'
else
  broadcast_option='1'
fi

# Underscore option
if [ $underscore = "True" ]; then
  trailing='_'
else
  trailing=$(echo ' ')
fi

# broadcast WiFi Hotspots, SL MAC
random_bssid='74:F8:DB:40:00:00'

# broadcast on channel 11 for first load only
channel_number='11'

## Randomized Variables

  # Randomize the trailing digits
  random=${trailing}$(shuf -z -r -i1-9 -n${digit_length})

# Make sure hostapd + dnsmasq are installed
if [ ! -d '/etc/hostapd' ] || [ ! -d '/etc/dnsmasq.d' ]; then
  clear
  echo "
	- - - - - - - - - - - - - - -
	DYNAMIC Wi-Fi HONEYPOT SCRIPT
	- - - - - - - - - - - - - - -

	* NOTE: Please check that \"""hostapd\""" and \"""dnsmasq\""" are installed
	* Script is unable to run as expected"

  sleep 3

  echo "
	* goodbye

"
  exit 1
elif [ ! -d $honeypot ]; then
  clear
  echo "
	- - - - - - - - - - - - - - -
	DYNAMIC Wi-Fi HONEYPOT SCRIPT
	- - - - - - - - - - - - - - -

	* NOTE: Please check that you copied the honeypot files correctly
	* Script is unable to run as expected"

  sleep 3

  echo "
	* goodbye

"
  sleep 3
  exit 1
fi


#
#  Prepare To Load
#

# Clear the system log
sudo sh $clear_syslog

# Make sure log files exists
if [ ! -f $master_mac ]; then
  touch $master_mac
fi

# Make sure the hostapd conf exists
if [ ! -f $hostapd_conf ]; then
  touch $hostapd_conf
fi

# kill a box of kittens
if [ -d $honeypot ]; then
  sudo chmod 777 -R $honeypot
fi


#
#  Update hostapd conf
#

# ! this scrip dynamically updates the "ssid=", "bssid=", "wpa_passphrase=",
# "ignore_broadcast_ssid=" & "channel" lines of the hostapd configuration file
#
# ! it is safe to add or edit whatever other lines to customize for your needs
# ! RPI2 users can add a "driver=" line or change the interface for USB Wi-Fi
# which will get this honeypot working as expected, USB needs Linux + AP support
#
# ! Warning! hostapd does not like empty space or some other text situations
# ! more hostapd.conf info @https://w1.fi/cgit/hostap/plain/hostapd/hostapd.conf


## Write These Defaults To The HostAPD Configuration File
cat <<EOF > $hostapd_conf
# File dynamically updated
$script_path__comment
interface=wlan0
ssid=$default_ssid${random}
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

# check hostapd is running
if sudo service hostapd | grep dead; then
  sudo sh $hostapd_restart
fi
if sudo service hostapd status | grep exited; then
  sudo service hostapd force-reload
fi

echo '	 Wi-Fi Honeypot Is Loading...'
if ! sudo fdisk -l | grep dev/sda1; then
  echo  '	 Insert USB and reboot to regain terminal access'
fi


## Restart HostAPD
# ! HostAPD would sometimes fail to broadcast on boot
sudo sh $hostapd_restart
clear

echo "Wi-Fi Honeypot is broadcasting \"""${default_ssid}${random}\"""

"
echo 'Scanning for connection attempts...

'
if grep -q ":" $master_mac; then
  echo '
- - - - - - - -
Logged Devices
- - - - - - - -
'
  cat $master_mac
  echo '

'
else
  echo '
- - - - - - - -
Logged Devices
- - - - - - - -

No devices are logged
'
fi



## Infinite Loop
while :
do


  # slow the loop down
  sleep 4

  # count loop passes
  loop_pass=$((loop_pass+1))

  # check if user wants a reboot
  if [ $reboot_system = "True" ]; then
    if [ "$loop_pass" -gt "$reboot_on_loop" ]; then
      sudo sh $system_reboot
    fi
  fi

  # grab the latest mac address (singular) that tried to connect - Dynamic SSIDs
  echo_mac=$(grep associated $syslog | tail -1 | awk 'BEGIN { getline; print toupper($8) }')

  # grab the latest mac addresses (multiple) that tried to connect - Mac Logs
  save_mac=$(grep associated $syslog | awk 'BEGIN { getline; print toupper($8) }' | sort -u)





#
# DYNAMIC SSID BROADCAST RESPONSES
#
#  ! These dynamic broadcast responses are editable ^ in the script settings
#





  # - - - - - - - - - - - - - -
  # CONNECTION ATTEMPT DETECTED
  # - - - - - - - - - - - - - -

  if grep associated $syslog; then

    echo "Device $echo_mac is trying to connect"

    # log the mac address
    echo $echo_mac >> $master_mac
    echo '' >> $master_mac
    sort -u $master_mac -o $master_mac

    #
    # Dynamic SSID
    #

    # Randomize the trailing digits
    random=${trailing}$(shuf -z -r -i1-9 -n${digit_length})

    # Spoof and randomize the last two digits of the new bssid
    random_bssid='74:F8:DB:40:00:'$(shuf -z -i1-9 -n2)

    # Randomize the Wi-Fi channel but only use channels 1 6 or 11
    channel_number=$(printf '1\n6\n11\n' | shuf -n1)

    ## Update hostapd conf
    sed -i '/^ssid=.*/c\ssid='"${default_ssid}${random}" $hostapd_conf
    sed -i '/^bssid=.*/c\bssid='"${random_bssid}" $hostapd_conf
    sed -i '/^ignore_broadcast_ssid=.*/c\ignore_broadcast_ssid='"${broadcast_option}" $hostapd_conf
    sed -i '/^channel=.*/c\channel='"${channel_number}" $hostapd_conf

    # restart hostapd
    sudo sh $hostapd_restart
    echo $echo_mac
    clear

    echo "Wi-Fi Honeypot is broadcasting \"""${default_ssid}${random}\"""

"
    echo "Device \"""${echo_mac}\""" was attempting to connect

"

    if grep -q ":" $master_mac; then
      echo '
- - - - - - - -
Logged Devices
- - - - - - - -
'
      cat $master_mac
      echo '

'
    fi

    # clear the syslog before the next pass
    sudo sh $clear_syslog

  fi #/CONNECTION ATTEMPT DETECTED




done #/Infinite Loop
