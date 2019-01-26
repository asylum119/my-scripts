#!/bin/sh
# rc.local exit trap - boot with USB plugged into RPI to regain terminal access
if sudo fdisk -l | grep /dev/sda1; then
exit 0
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
#  Project:      Dynamic Wi-Fi Honeypot 4RPI3
#                 -  Alien Wi-Fi Beacon Script
#
#  Version:      Proof Of Concept
#  Author:       Brett Peters, 2017
#  Contact:      asylum119@hotmail.com
#
#
#  DESCRIPTION
#
#  Use the RPI3s onboard Wi-Fi interface to broadcast a
#  single Dynamic Wi-Fi AP, then rotate through 10 SSID
#  responses in short succession upon connection attempt.
#
#  This script dynamically updates the broadcast SSID with
#  several predefined response when a connection attempt is
#  made on the default SSID. The SSID responses are rotated
#  through in quick succession before falling back to broadcast
#  the default SSID untill the next connection attempt is made.
#
#  This particular script is an alien welcome beacon that reveals
#  a communication response for those curious enough to attempt to
#  make a connection. The response is bad news for the human race.
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
#  Default SSID Name
#
#  ! This is the default Wi-Fi Broadcast name.
#

   default_ssid="Extraterrestrial Welcome Beacon"




  #
  #  SSID Response 1
  #

     dynamic_ssid_1="Greetings Earthling"




  #
  #  SSID Response 2
  #

     dynamic_ssid_2="We Have Received Communications"




  #
  #  SSID Response 3  -  "From Device <mac address>
  #
  #  ! Broadcast the mac address of the device attempting to connect (17 characters + 1 space)
  #

     dynamic_ssid_3='From Device'




  #
  #  SSID Response 4
  #

     dynamic_ssid_4="We Have Concluded The Following"




  #
  #  SSID Response 5
  #

     dynamic_ssid_5="No intelligent life on Earth"




  #
  #  SSID Response 6
  #

     dynamic_ssid_6="We Will Now Invade Your Planet"




  #
  #  SSID Response 7
  #

     dynamic_ssid_7="Zap... POW!... Pew Pew Peew"




  #
  #  SSID Response 8
  #

     dynamic_ssid_8="KING KONG AINT GOT NOTHING ON ME"




  #
  #  SSID Response 9
  #

     dynamic_ssid_9="ZAP!... Pow... Pew Pew Peew"




  #
  #  SSID Response 10
  #

     dynamic_ssid_10="Pew Pew... Pew Pew... Peew"




  #
  #  Unable To Broadcast Mac Address  -  (fallback)
  #
  #  ! mac addresses that do not meet our sanitation requirements for an SSID broadcast
  #  will trigger this SSID fallback broadcast without a mac address in the SSID, this
  #  should only occur if a hacker spoofs a mac address outside the normal parameters.
  #

     dynamic_ssid__not_sanitized="From an Unknown Device"




    #
    #  Broadcast Time
    #
    #  ! Set the broadcast time for the dynamic SSID responses,
    #  once the time limit has been reached the honeypot will
    #  move onto broadcasting the next Wi-Fi name in line.
    #
    #  ! HostAPD needs time to restart and devices also need
    #  some time to update the new Wi-Fi name. (keep above 20)
    #

       broadcast_time="20"




#
#  Hidden Or Public Broadcasts
#
#  ! This setting is "True" by default allowing the Wi-Fi name to
#  be viewable by the public, change to "False" if you want the
#  honeypot to broadcast as a hidden Wi-Fi network instead.
#

   public_broadcast="True"




#
#  Access Point Passphrase
#
#  ! This is the Wi-Fi password, although both DNS and network
#  have not been set up, the aim is to deter a correct guess.
#

   ssid_pass="!@Qhg@mk:aaaaaaaaa11111111111a11aa1!::::"




#
#  System Reboot
#
#  ! This setting is "True" by default allowing the RPI to reboot
#  once a script loop count has been reached. each script pass takes
#  approximately 4 seconds and if using rc.local the honeypot will
#  resume automatically. Set to "False" to never reboot the RPI.
#

   reboot_system="True"


    # reboot after this many script passes
      reboot_on_loop="20000"




# - - - - - - - - - - - - - -
# Script Settings - ADVANCED
# - - - - - - - - - - - - - -



# Log file (detected mac addresses)
master_mac="/etc/honeypot/log/master-mac"  # Master MAC Log used by all honeypot scripts
tmp_log="/etc/honeypot/tmp/temp"

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
echo "\033]0;Wi-Fi Honeypot - Alien Welcome Beacon\a"
clear

# Script path
script_path__comment="# see ${script_dir}/$0"

# Public broadcast option
if [ $public_broadcast = "True" ]; then
  broadcast_option='0'
else
  broadcast_option='1'
fi

# broadcast NSA mac address for first load only (easily identify honeypot status with remote SSID + BSSID scan)
random_bssid='00:20:91:00:00:00'

# broadcast on channel 11 for first load only
channel_number='11'

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
if [ ! -f $tmp_log ]; then
  touch $tmp_log
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

echo "Wi-Fi Honeypot is broadcasting \"""$default_ssid\"""

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
  if [ $reboot_system = "True" ] && grep -q "$default_ssid" $hostapd_conf; then
    if [ "$loop_pass" -gt "$reboot_on_loop" ]; then
      sudo sh $system_reboot
    fi
  fi

  # grab the latest mac addresses (multiple) that tried to connect - Mac Logs
  save_mac=$(grep associated $syslog | awk 'BEGIN { getline; print toupper($8) }' | sort -u)

  # grab the latest mac address (singular) that tried to connect - Dynamic SSIDs
  echo_mac=$(grep associated $syslog | tail -1 | awk 'BEGIN { getline; print toupper($8) }')





#
# DYNAMIC SSID BROADCAST RESPONSES
#
#  ! These dynamic broadcast responses are editable ^ in the script settings
#





  # - - - - - - - - - - - - - -
  # CONNECTION ATTEMPT DETECTED
  # - - - - - - - - - - - - - -

  if grep associated $syslog && grep -q "$default_ssid" $hostapd_conf; then

    echo $echo_mac

    echo $echo_mac > $tmp_log
    session_mac=$(cat $tmp_log)

    echo "Device $session_mac is trying to connect"

    # log the mac address
    echo $session_mac >> $master_mac
    sort -u $master_mac -o $master_mac



    #
    # Dynamic SSID 1
    #

    # Spoof and randomize the last two digits of the new bssid
    random_bssid='00:20:91:00:00:'$(shuf -z -i1-9 -n2)

    # Randomize the Wi-Fi channel but only use channels 1 6 or 11
    channel_number=$(printf '1\n6\n11\n' | shuf -n1)

    ## Update hostapd conf
    sed -i '/^ssid=.*/c\ssid='"${dynamic_ssid_1}" $hostapd_conf
    sed -i '/^bssid=.*/c\bssid='"${random_bssid}" $hostapd_conf
    sed -i '/^ignore_broadcast_ssid=.*/c\ignore_broadcast_ssid='"${broadcast_option}" $hostapd_conf
    sed -i '/^channel=.*/c\channel='"${channel_number}" $hostapd_conf

    # restart hostapd
    sudo sh $hostapd_restart
    clear

    echo "Wi-Fi Honeypot is broadcasting \"""${dynamic_ssid_1}\"""

"
    echo "Device \"""$session_mac\""" is attempting to connect

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

    # broadcast time (in seconds)
    sleep $broadcast_time



    #
    # Dynamic SSID 2
    #

    # Spoof and randomize the last two digits of the new bssid
    random_bssid='00:20:91:00:00:'$(shuf -z -i1-9 -n2)

    # Randomize the Wi-Fi channel but only use channels 1 6 or 11
    channel_number=$(printf '1\n6\n11\n' | shuf -n1)

    ## Update hostapd conf
    sed -i '/^ssid=.*/c\ssid='"${dynamic_ssid_2}" $hostapd_conf
    sed -i '/^bssid=.*/c\bssid='"${random_bssid}" $hostapd_conf
    sed -i '/^ignore_broadcast_ssid=.*/c\ignore_broadcast_ssid='"${broadcast_option}" $hostapd_conf
    sed -i '/^channel=.*/c\channel='"${channel_number}" $hostapd_conf

    # restart hostapd
    sudo sh $hostapd_restart
    clear

    echo "Wi-Fi Honeypot is broadcasting \"""${dynamic_ssid_2}\"""

"
    echo "Device \"""$session_mac\""" is attempting to connect

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

    # broadcast time (in seconds)
    sleep $broadcast_time



    #
    # Dynamic SSID 3
    #

    # Spoof and randomize the last two digits of the new bssid
    random_bssid='00:20:91:00:00:'$(shuf -z -i1-9 -n2)

    # Randomize the Wi-Fi channel but only use channels 1 6 or 11
    channel_number=$(printf '1\n6\n11\n' | shuf -n1)

    ## Update hostapd conf
    if sanitize_mac=$(echo "$session_mac" | grep -Eio '\b([[:xdigit:]]{1,2}[:-]){5}[[:xdigit:]]{1,2}\b'); then
      # mac IS sanitized - (! MAC is in SSID)
      sed -i '/^ssid=.*/c\ssid='"${dynamic_ssid_3} ${session_mac}" $hostapd_conf
    else
      # mac NOT sanitized
      sed -i '/^ssid=.*/c\ssid='"${dynamic_ssid__not_sanitized}" $hostapd_conf
    fi
    sed -i '/^bssid=.*/c\bssid='"${random_bssid}" $hostapd_conf
    sed -i '/^ignore_broadcast_ssid=.*/c\ignore_broadcast_ssid='"${broadcast_option}" $hostapd_conf
    sed -i '/^channel=.*/c\channel='"${channel_number}" $hostapd_conf

    # restart hostapd
    sudo sh $hostapd_restart
    clear

    if sanitize_mac=$(echo "$session_mac" | grep -Eio '\b([[:xdigit:]]{1,2}[:-]){5}[[:xdigit:]]{1,2}\b'); then
      # mac IS sanitized - (! MAC is in SSID)
      echo "Wi-Fi Honeypot is broadcasting \"""${dynamic_ssid_3} ${session_mac}\"""

"
    else
      # mac NOT sanitized
      echo "Wi-Fi Honeypot is broadcasting \"""${dynamic_ssid__not_sanitized}\"""

"
    fi

    echo "Device \"""$session_mac\""" is attempting to connect

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

    # broadcast time (in seconds)
    sleep $broadcast_time



    #
    # Dynamic SSID 4
    #

    # Spoof and randomize the last two digits of the new bssid
    random_bssid='00:20:91:00:00:'$(shuf -z -i1-9 -n2)

    # Randomize the Wi-Fi channel but only use channels 1 6 or 11
    channel_number=$(printf '1\n6\n11\n' | shuf -n1)

    ## Update hostapd conf
    sed -i '/^ssid=.*/c\ssid='"${dynamic_ssid_4}" $hostapd_conf
    sed -i '/^bssid=.*/c\bssid='"${random_bssid}" $hostapd_conf
    sed -i '/^ignore_broadcast_ssid=.*/c\ignore_broadcast_ssid='"${broadcast_option}" $hostapd_conf
    sed -i '/^channel=.*/c\channel='"${channel_number}" $hostapd_conf

    # restart hostapd
    sudo sh $hostapd_restart
    clear

    echo "Wi-Fi Honeypot is broadcasting \"""${dynamic_ssid_4}\"""

"
    echo "Device \"""$session_mac\""" is attempting to connect

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

    # broadcast time (in seconds)
    sleep $broadcast_time



    #
    # Dynamic SSID 5
    #

    # Spoof and randomize the last two digits of the new bssid
    random_bssid='00:20:91:00:00:'$(shuf -z -i1-9 -n2)

    # Randomize the Wi-Fi channel but only use channels 1 6 or 11
    channel_number=$(printf '1\n6\n11\n' | shuf -n1)

    ## Update hostapd conf
    sed -i '/^ssid=.*/c\ssid='"${dynamic_ssid_5}" $hostapd_conf
    sed -i '/^bssid=.*/c\bssid='"${random_bssid}" $hostapd_conf
    sed -i '/^ignore_broadcast_ssid=.*/c\ignore_broadcast_ssid='"${broadcast_option}" $hostapd_conf
    sed -i '/^channel=.*/c\channel='"${channel_number}" $hostapd_conf

    # restart hostapd
    sudo sh $hostapd_restart
    clear

    echo "Wi-Fi Honeypot is broadcasting \"""${dynamic_ssid_5}\"""

"
    echo "Device \"""$session_mac\""" is attempting to connect

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

    # broadcast time (in seconds)
    sleep $broadcast_time



    #
    # Dynamic SSID 6
    #

    # Spoof and randomize the last two digits of the new bssid
    random_bssid='00:20:91:00:00:'$(shuf -z -i1-9 -n2)

    # Randomize the Wi-Fi channel but only use channels 1 6 or 11
    channel_number=$(printf '1\n6\n11\n' | shuf -n1)

    ## Update hostapd conf
    sed -i '/^ssid=.*/c\ssid='"${dynamic_ssid_6}" $hostapd_conf
    sed -i '/^bssid=.*/c\bssid='"${random_bssid}" $hostapd_conf
    sed -i '/^ignore_broadcast_ssid=.*/c\ignore_broadcast_ssid='"${broadcast_option}" $hostapd_conf
    sed -i '/^channel=.*/c\channel='"${channel_number}" $hostapd_conf

    # restart hostapd
    sudo sh $hostapd_restart
    clear

    echo "Wi-Fi Honeypot is broadcasting \"""${dynamic_ssid_6}\"""

"
    echo "Device \"""$session_mac\""" is attempting to connect

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

    # broadcast time (in seconds)
    sleep $broadcast_time



    #
    # Dynamic SSID 7
    #

    # Spoof and randomize the last two digits of the new bssid
    random_bssid='00:20:91:00:00:'$(shuf -z -i1-9 -n2)

    # Randomize the Wi-Fi channel but only use channels 1 6 or 11
    channel_number=$(printf '1\n6\n11\n' | shuf -n1)

    ## Update hostapd conf
    sed -i '/^ssid=.*/c\ssid='"${dynamic_ssid_7}" $hostapd_conf
    sed -i '/^bssid=.*/c\bssid='"${random_bssid}" $hostapd_conf
    sed -i '/^ignore_broadcast_ssid=.*/c\ignore_broadcast_ssid='"${broadcast_option}" $hostapd_conf
    sed -i '/^channel=.*/c\channel='"${channel_number}" $hostapd_conf

    # restart hostapd
    sudo sh $hostapd_restart
    clear

    echo "Wi-Fi Honeypot is broadcasting \"""${dynamic_ssid_7}\"""

"
    echo "Device \"""$session_mac\""" is attempting to connect

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

    # broadcast time (in seconds)
    sleep $broadcast_time



    #
    # Dynamic SSID 8
    #

    # Spoof and randomize the last two digits of the new bssid
    random_bssid='00:20:91:00:00:'$(shuf -z -i1-9 -n2)

    # Randomize the Wi-Fi channel but only use channels 1 6 or 11
    channel_number=$(printf '1\n6\n11\n' | shuf -n1)

    ## Update hostapd conf
    sed -i '/^ssid=.*/c\ssid='"${dynamic_ssid_8}" $hostapd_conf
    sed -i '/^bssid=.*/c\bssid='"${random_bssid}" $hostapd_conf
    sed -i '/^ignore_broadcast_ssid=.*/c\ignore_broadcast_ssid='"${broadcast_option}" $hostapd_conf
    sed -i '/^channel=.*/c\channel='"${channel_number}" $hostapd_conf

    # restart hostapd
    sudo sh $hostapd_restart
    clear

    echo "Wi-Fi Honeypot is broadcasting \"""${dynamic_ssid_8}\"""

"
    echo "Device \"""$session_mac\""" is attempting to connect

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

    # broadcast time (in seconds)
    sleep $broadcast_time



    #
    # Dynamic SSID 9
    #

    # Spoof and randomize the last two digits of the new bssid
    random_bssid='00:20:91:00:00:'$(shuf -z -i1-9 -n2)

    # Randomize the Wi-Fi channel but only use channels 1 6 or 11
    channel_number=$(printf '1\n6\n11\n' | shuf -n1)

    ## Update hostapd conf
    sed -i '/^ssid=.*/c\ssid='"${dynamic_ssid_9}" $hostapd_conf
    sed -i '/^bssid=.*/c\bssid='"${random_bssid}" $hostapd_conf
    sed -i '/^ignore_broadcast_ssid=.*/c\ignore_broadcast_ssid='"${broadcast_option}" $hostapd_conf
    sed -i '/^channel=.*/c\channel='"${channel_number}" $hostapd_conf

    # restart hostapd
    sudo sh $hostapd_restart
    clear

    echo "Wi-Fi Honeypot is broadcasting \"""${dynamic_ssid_9}\"""

"
    echo "Device \"""$session_mac\""" is attempting to connect

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

    # broadcast time (in seconds)
    sleep $broadcast_time



    #
    # Dynamic SSID 10
    #

    # Spoof and randomize the last two digits of the new bssid
    random_bssid='00:20:91:00:00:'$(shuf -z -i1-9 -n2)

    # Randomize the Wi-Fi channel but only use channels 1 6 or 11
    channel_number=$(printf '1\n6\n11\n' | shuf -n1)

    ## Update hostapd conf
    sed -i '/^ssid=.*/c\ssid='"${dynamic_ssid_10}" $hostapd_conf
    sed -i '/^bssid=.*/c\bssid='"${random_bssid}" $hostapd_conf
    sed -i '/^ignore_broadcast_ssid=.*/c\ignore_broadcast_ssid='"${broadcast_option}" $hostapd_conf
    sed -i '/^channel=.*/c\channel='"${channel_number}" $hostapd_conf

    # restart hostapd
    sudo sh $hostapd_restart
    clear

    echo "Wi-Fi Honeypot is broadcasting \"""${dynamic_ssid_10}\"""

"
    echo "Device \"""$session_mac\""" is attempting to connect

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

    # broadcast time (in seconds)
    sleep $broadcast_time

    # check if multiple devices tried to connect and save macs
    echo $save_mac >> $master_mac
    sort -u $master_mac -o $master_mac

    # reset the temp file
    echo '' > $tmp_log

    # clear the syslog before the next pass
    sudo sh $clear_syslog

 # fi #/Dynamic SSIDs




  # - - - - - - - - - - - -
  # DEFAULT SSID - FALLBACK
  # - - - - - - - - - - - -

  elif ! grep associated $syslog && ! grep -q "$default_ssid" $hostapd_conf; then

    # Spoof and randomize the last two digits of the new bssid
    random_bssid='00:20:91:00:00:'$(shuf -z -i1-9 -n2)

    # Randomize the Wi-Fi channel but only use channels 1 6 or 11
    channel_number=$(printf '1\n6\n11\n' | shuf -n1)

    ## Update hostapd conf
    sed -i '/^ssid=.*/c\ssid='"${default_ssid}" $hostapd_conf
    sed -i '/^bssid=.*/c\bssid='"${random_bssid}" $hostapd_conf
    sed -i '/^ignore_broadcast_ssid=.*/c\ignore_broadcast_ssid='"${broadcast_option}" $hostapd_conf
    sed -i '/^channel=.*/c\channel='"${channel_number}" $hostapd_conf

    # restart hostapd
    sudo sh $hostapd_restart
    clear

    echo "Wi-Fi Honeypot is broadcasting \"""$default_ssid\"""

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

    # clear the syslog before the next pass
    sudo sh $clear_syslog


  fi #/Default




done #/Infinite Loop
