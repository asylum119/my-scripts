#!/bin/sh
# rc.local exit trap - boot with USB plugged into RPI to regain terminal access
if sudo fdisk -l | grep /dev/sda1; then
exit 0
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
#  Project:      Dynamic Wi-Fi Honeypot 4RPI3
#                 -  Escalated SSID Response Script
#
#  Version:      Proof Of Concept
#  Author:       Brett Peters, 2017
#  Contact:      asylum119@hotmail.com
#
#
#  DESCRIPTION
#
#  Use the RPI3s onboard Wi-Fi interface to broadcast a single Dynamic Wi-Fi AP
#  and log the mac addresses of any device that attempts to make a connection,
#
#  This script dynamically updates the broadcast SSID with an escalated response
#  on a device per device basis, those that attempt many connection attempts are
#  shown more unique SSID responses. Persistent connection attempts result in the
#  devices mac address being jailed, they will never see the initial SSID responses
#  again, instead the SSID response will now randomize through a separate SSID list.
#
#  This is a good warning to Wi-Fi Pen Tester / Bad Neighbours as the first response
#  to a connection attempt broadcasts their devices mac address. Using escalated MAC
#  logging a router system admin can get a clearer threat assessment of nearby devices.
#
#
#  DEFAULT BROADCAST EXAMPLE
#
#  Honeypot is waiting on a connection attempt
#  * Default SSID broadcast    "WeLogYourHacking_"                 <-- Default SSID Name
#
#    Newly detected device IS attempted to connect
#    * Response SSID broadcast "Device <device-mac> Logged"          <-- First SSID Response
#
#    Device has tried to connect once before
#    * Response SSID broadcast "Device Already Logged - Go Away"     <-- Second SSID Response
#
#    Device has tried to connect two times before
#    * Response SSID broadcast "PEN TEST YOUR OWN NETWORKS"          <-- Third SSID Response
#
#    Device IS trying to connect and is considered a threat
#    * Response SSID broadcast "Wi-Fi Threat <device-mac>"           <-- Fourth SSID Response
#
#  Device is jailed
#  * Broadcast a jailed SSID (picked at random)                    <-- Device Is Jailed Response
#
#
#  MAC ADDRESS LOGS
#
#  * honeypot/log/honeypot/devices-1      <-- single connection attempts
#  * honeypot/log/honeypot/devices-2      <-- duel connection attempts
#  * honeypot/log/honeypot/devices-3      <-- triple connection attempts
#  * honeypot/log/honeypot/devices-4      <-- device is jailed
#  * honeypot/log/master-mac              <-- Master MAC Log used by all honeypot scripts
#
#
#  NOTES
#
#  To reset a mac address you must remove the MAC from all
#  4 of the 'devices-*' files, or delete all of the 'devices-*'
#  files to reset all MACS (script will recreate these files)
#
#  /var/log/syslog gets cleared out by this script to combat
#  the RPI not having onboard time to use up to date time
#  stamps, something to consider if wanting to implement on a
#  NON single project RPI or use on a different machine
#
#  SSID broadcast names have a 31 character limit as well as not
#  allowing some special characters.
#
#  Broadcast times do not have a minimum time set. When using
#  low numbering, allow time for hostapd to reload as well as
#  giving devices enough time to pickup the new SSID broadcast
#
#
#  REQUIREMENTS
#
#  * RPI2
#  * GNU/Linux
#  * HostAPD
#  * Dnsmasq
#  * Edit conf files (hostapd needs to point to the new conf file)
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -




# - - - - - - - - - - - - -
# Script Settings - SSID
# - - - - - - - - - - - - -




#
#  Default SSID Name
#
#  ! This is the default Wi-Fi Broadcast name.
#

   default_ssid="Can't Hack This"




#
#  SSID Response 1  -  "Device <mac address> Logged"
#
#  ! Display this SSID when a new device attempts to connect
#

   # Leading SSID Name (before mac address)
   dynamic_ssid_1__before_mac="Device"

   # Trailing SSID Name (after mac address)
   dynamic_ssid_1__after_mac="Logged"

     # SSID broadcast SSID Time	(in seconds; keep above 20)
     dynamic_ssid_1__time="600"




#
#  SSID Response 2  -  "Device Already Logged - Go Away"
#
#  ! Display this SSID when a device has attempted to connect one time
#

   # SSID Name
   dynamic_ssid_2="Device Already Logged - Go Away"

     # SSID broadcast Time	(in seconds; keep above 20)
     dynamic_ssid_2__time="120"




#
#  SSID Response 3  -  "PEN TEST YOUR OWN NETWORK"
#
#  ! Display this SSID when a device has attempted to connect two times
#

   # SSID Name
   dynamic_ssid_3="PEN TEST YOUR OWN NETWORK"

     # SSID broadcast Time	(in seconds; keep above 20)
     dynamic_ssid_3__time="120"




#
#  SSID Response 4  -  "Wi-Fi Threat <mac address>"
#
#  ! Display this SSID when a device has attempted to connect three times
#

   # Leading SSID Name (before mac address)
   dynamic_ssid_4__before_mac="Wi-Fi Threat"

     # SSID broadcast Time	(in seconds; keep above 20)
      dynamic_ssid_4__time="600"




#
#  SSID MAC Fallback -  "Oh Snap! That Was A Tad Fancy"
#
#  ! mac addresses that fail our sanitation check will not be broadcasted in the
#  SSID. the following will be broadcasted instead of the users mac address.
#

   # SSID Name
    dynamic_ssid__not_sanitized="Oh Snap! That Was A Tad Fancy"

		# ! Broadcast Time is taken from the SSID settings prior to the fallback




#
#  SSID Response 5  -  "<randomized jail responses>"
#
#  ! a jailed device is one that has pen tested the network to exhaustion
#  ! a jailed device can only trigger one of the following SSIDs (picked at random)
#

   # * detected on Wi-Fi
   jail_ssid_1="Script Kiddie detected on Wi-Fi"
   jail_ssid_2="Brony detected on Wi-Fi"
   jail_ssid_3="Noob detected on Wi-Fi"
   jail_ssid_4="War Driver detected on Wi-Fi"
   jail_ssid_5="Pen Tester detected on Wi-Fi"
   jail_ssid_6="Bad Neighbour detected on Wi-Fi"

   # Wi-Fi is being *
   jail_ssid_7="Wi-Fi is being Brute Forced"
   jail_ssid_8="Wi-Fi is being Pen Tested"

   # Wi-Fi Status: *
   jail_ssid_9="Wi-Fi Status: Active Threat"
   jail_ssid_10="Wi-Fi Status: Active Attack"


     # SSID broadcast Time	(in seconds; keep above 20)
     jailed_ssid__time="120"




#
#  Hidden Or Public Broadcasts (beta - TODO: add mac spoofing for probe requests)
#
#  ! This setting is "True" by default allowing the Wi-Fi name to
#  be viewable by the public, change to "False" if you want the
#  honeypot to broadcast as a hidden Wi-Fi network instead.
#

   public_broadcast="False"



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



# set the Wi-Fi interface
wifi_interface="wlan0"
# Log file (detected mac addresses)
mac_log="/etc/honeypot/log/honeypot/devices-1"      # Device already logged
mac_log_2="/etc/honeypot/log/honeypot/devices-2"    # Device is hacking
threat_log="/etc/honeypot/log/honeypot/devices-3"   # Device is a threat
in_jail="/etc/honeypot/log/honeypot/devices-4"      # Device is in jail
master_mac="/etc/honeypot/log/master-mac"           # Master MAC Log used by all scripts

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
echo "\033]0;Wi-Fi Honeypot - Escalated Response\a"
clear

# Script path
script_path__comment="# see ${script_dir}/$0"

# Public broadcast option
if [ $public_broadcast = "True" ]; then
  broadcast_option='0'
else
  broadcast_option='1'
fi

# spoof and randomize a technicolor router MAC on first loads
random_number=$(shuf -z -i1-9 -n1)
random_letter=$(printf "A\nB\nC\nD\nE\nF\n" | shuf -n1)
random_bssid='C4:EA:1D:17:E${random_number}:${random_number}${random_letter}'

# randomize the channel on first load
random_channel=$(printf "11\n6\n9\n" | shuf -n1)
channel_number=$random_channel


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
if [ ! -f $mac_log ]; then
  touch $mac_log
fi
if [ ! -f $mac_log_2 ]; then
 touch $mac_log_2
fi
if [ ! -f $threat_log ]; then
  touch $threat_log
fi
if [ ! -f $in_jail ]; then
  touch $in_jail
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
interface=$wifi_interface
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
if grep -q ":" $mac_log; then
  echo '
- - - - - - - -
Logged Devices
- - - - - - - -
'
  cat $mac_log
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


  # grab the latest mac address (singular) that tried to connect - Dynamic SSIDs
  echo_mac=$(grep associated $syslog | tail -1 | awk 'BEGIN { getline; print toupper($8) }')

  # grab the latest mac addresses (multiple) that tried to connect - Mac Logs
  save_mac=$(grep associated $syslog | awk 'BEGIN { getline; print toupper($8) }' | sort -u)

  # Randomize the Wi-Fi channel but only use channels 1 6 or 11
  channel_number=$(printf '1\n6\n11\n' | shuf -n1)


  #
  #  Construct some mac addresses
  #

  # random mac numbers
  N1=$(shuf -z -i1-9 -n1); N2=$(shuf -z -i1-9 -n1); N3=$(shuf -z -i1-9 -n1); N4=$(shuf -z -i1-9 -n1); N5=$(shuf -z -i1-9 -n1); N6=$(shuf -z -i1-9 -n1); N7=$(shuf -z -i1-9 -n1); N8=$(shuf -z -i1-9 -n1); N9=$(shuf -z -i1-9 -n1); N10=$(shuf -z -i1-9 -n1); N11=$(shuf -z -i1-9 -n1); N12=$(shuf -z -i1-9 -n1)

  # random mac letters
  RML="A\nB\nC\nD\nE\nF\n"
  U1=$(printf $RML | shuf -n1); U2=$(printf $RML | shuf -n1); U3=$(printf $RML | shuf -n1); U4=$(printf $RML | shuf -n1); U5=$(printf $RML | shuf -n1); U6=$(printf $RML | shuf -n1); U7=$(printf $RML | shuf -n1); U8=$(printf $RML | shuf -n1); U9=$(printf $RML | shuf -n1); U10=$(printf $RML | shuf -n1); U11=$(printf $RML | shuf -n1); U12=$(printf $RML | shuf -n1)


  ## spoof some MAC prefixes + randomize

    # CISCO SYSTEMS, INC.
    M1=00:01:42:${N1}${N2}:${N3}${N4}:${N5}${U6}; M2=00:0F:F7:${N1}${N2}:${U3}${N4}:${N5}${N6}; M3=00:14:6A:${U1}${U2}:${N3}${N4}:${N5}${N6}; M4=00:13:7F:${N1}${N2}:${U3}${N4}:${N5}${U6}; M5=00:01:43:${U1}${N2}:${U3}${U4}:${U5}${N6}

    # ASUSTek COMPUTER INC.
    M6=D8:50:E6:${N1}${N2}:${N3}${N4}:${N5}${N6}; M7=00:0C:6E:${N1}${N2}:${N3}${N4}:${U5}${U6}; M8=FC:C2:33:${U1}${N2}:${N3}${N4}:${N5}${N6}; M9=C8:60:00:${N1}${U2}:${U3}${N4}:${N5}${U6}; M10=E0:3F:49:${N1}${N2}:${U3}${U4}:${N5}${U6}

    # NETGEAR
    M11=6C:B0:CE:${N1}${N2}:${N3}${N4}:${N5}${N6}; M12=6C:B0:CE:${U1}${N2}:${U3}${N4}:${U5}${N6}; M13=6C:B0:CE:${N1}${U2}:${N3}${U4}:${N5}${N6}; M14=74:44:01:${N1}${N2}:${U3}${N4}:${N5}${N6}; M15=74:44:01:${N1}${N2}:${U3}${U4}:${N5}${N6}

    # TRENDnet
    M16=00:14:D1:${N1}${U2}:${N3}${N4}:${N5}${N6}; M17=00:14:D1:${U1}${N2}:${N3}${N4}:${N5}${N6}; M18=D8:EB:97:${N1}${N2}:${U3}${U4}:${N5}${N6}; M19=D8:EB:97:${N1}${N2}:${N3}${N4}:${U5}${U6}; M20=D8:EB:97:${N1}${U2}:${N3}${N4}:${U5}${N6}


  # final singular random mac output
  random_bssid=$(printf "${M1}\n${M2}\n${M3}\n${M4}\n${M5}\n${M6}\n${M7}\n${M8}\n${M9}\n${M10}\n${M11}\n${M12}\n${M13}\n${M14}\n${M15}\n${M16}\n${M17}\n${M18}\n${M19}\n${M20}\n" | shuf -n1)




  # - - - - - - - - - - - -
  # DEFAULT SSID - FALLBACK
  # - - - - - - - - - - - -

  # if SSID is hidden then send a request probe request
  if [ public_broadcast = " False" ] && grep -q "$default_ssid" $hostapd_conf; then
    sudo iwlist $wifi_interface scan essid "$default_ssid"
  fi

  if ! grep associated $syslog && ! grep -q "$default_ssid" $hostapd_conf; then

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
    if grep -q ":" $mac_log; then
      echo '
- - - - - - - -
Logged Devices
- - - - - - - -
'
      cat $mac_log
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


  fi #/DEFAULT SSID - FALLBACK




  # - - - - - - - - - - - - - - - - -
  # Dynamic SSID Escalated Responses
  # - - - - - - - - - - - - - - - - -


  #
  # NEW DEVICE DETECTED
  #

  if grep associated $syslog && ! grep $echo_mac $mac_log && ! grep $echo_mac $mac_log_2 && ! grep $echo_mac $threat_log && ! grep $echo_mac $in_jail && grep -q "$default_ssid" $hostapd_conf; then

    echo "New device $echo_mac is trying to connect"

    ## Update hostapd conf
    if sanitize_mac=$(echo "$echo_mac" | grep -Eio '\b([[:xdigit:]]{1,2}[:-]){5}[[:xdigit:]]{1,2}\b'); then
      # mac IS sanitized - (! MAC is in SSID)
      sed -i '/^ssid=.*/c\ssid='"${dynamic_ssid_1__before_mac} ${echo_mac} ${dynamic_ssid_1__after_mac}" $hostapd_conf
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

    # if SSID is hidden then send a request probe request
    if [ public_broadcast = " False" ]; then 
      grep_ssid=$(grep -Po '(?<=^ssid=).*' $hostapd_conf | tr -d \'\")
      sudo iwlist $wifi_interface scan essid "$grep_ssid"
    fi
  
    if sanitize_mac=$(echo "$echo_mac" | grep -Eio '\b([[:xdigit:]]{1,2}[:-]){5}[[:xdigit:]]{1,2}\b'); then
      # mac IS sanitized - (! MAC is in OSD)
      echo "Wi-Fi Honeypot is broadcasting \"""${dynamic_ssid_1__before_mac} ${echo_mac} ${dynamic_ssid_1__after_mac}\"""

"
      echo "Device \"""$echo_mac\""" is attempting to connect

"
    else
      # mac NOT sanitized
      echo "Wi-Fi Honeypot is broadcasting \"""${dynamic_ssid__not_sanitized}\"""

"
      echo "Device \"""$echo_mac\""" is attempting to connect with a non sanitized bssid

"
    fi

    # escalate mac logging
    echo '' >> $mac_log
    echo $echo_mac >> $mac_log
    echo '' >> $mac_log
    sort -u $mac_log -o $mac_log

    # master MAC log
    echo '' >> $master_mac
    echo $echo_mac >> $master_mac
    echo '' >> $master_mac
    sort -u $master_mac -o $master_mac

    if grep -q ":" $mac_log; then
      echo '
- - - - - - - -
Logged Devices
- - - - - - - -
'
      cat $mac_log
      echo '

'
    fi

    # if SSID is hidden then send a request probe request
    if [ public_broadcast = " False" ]; then 
      grep_ssid=$(grep -Po '(?<=^ssid=).*' $hostapd_conf | tr -d \'\")
      sudo iwlist $wifi_interface scan essid "$grep_ssid"
    fi
    
    # broadcast time (in seconds)
    sleep $dynamic_ssid_1__time

    # clear the syslog
    sudo sh $clear_syslog




  #
  # DEVICE IS ALREADY LOGGED
  #

  elif grep associated $syslog && grep $echo_mac $mac_log && ! grep $echo_mac $mac_log_2 && ! grep $echo_mac $threat_log && ! grep $echo_mac $in_jail && grep -q "$default_ssid" $hostapd_conf; then

    echo "Logged device $echo_mac is trying to connect"

    ## Update hostapd conf
    sed -i '/^ssid=.*/c\ssid='"${dynamic_ssid_2}" $hostapd_conf
    sed -i '/^bssid=.*/c\bssid='"${random_bssid}" $hostapd_conf
    sed -i '/^ignore_broadcast_ssid=.*/c\ignore_broadcast_ssid='"${broadcast_option}" $hostapd_conf
    sed -i '/^channel=.*/c\channel='"${channel_number}" $hostapd_conf

    # restart hostapd
    sudo sh $hostapd_restart
    clear

    # if SSID is hidden then send a request probe request
    if [ public_broadcast = " False" ]; then 
      sudo iwlist $wifi_interface scan essid "$dynamic_ssid_2"
    fi
    
    echo "Wi-Fi Honeypot is broadcasting \"""${dynamic_ssid_2}\"""

"
    echo "Device \"""$echo_mac\""" is attempting to connect

"

    # escalate mac logging
    echo '' >> $mac_log_2
    echo $echo_mac >> $mac_log_2
    echo '' >> $mac_log_2
    sort -u $mac_log_2 -o $mac_log_2

    if grep -q ":" $mac_log; then
      echo '
- - - - - - - -
Logged Devices
- - - - - - - -
'
      cat $mac_log
      echo '

'
    fi

    # if SSID is hidden then send a request probe request
    if [ public_broadcast = " False" ]; then 
      sudo iwlist $wifi_interface scan essid "$dynamic_ssid_2"
    fi
    
    # broadcast time (in seconds)
    sleep $dynamic_ssid_2__time

    # clear the syslog before the next pass
    sudo sh $clear_syslog




  #
  # DEVICE CONSIDERED HACKING
  #

  elif grep associated $syslog && grep $echo_mac $mac_log && grep $echo_mac $mac_log_2 && ! grep $echo_mac $threat_log && ! grep $echo_mac $in_jail && grep -q "$default_ssid" $hostapd_conf; then

    echo "Hacking device $echo_mac is trying to connect"

    ## Update hostapd conf
    sed -i '/^ssid=.*/c\ssid='"${dynamic_ssid_3}" $hostapd_conf
    sed -i '/^bssid=.*/c\bssid='"${random_bssid}" $hostapd_conf
    sed -i '/^ignore_broadcast_ssid=.*/c\ignore_broadcast_ssid='"${broadcast_option}" $hostapd_conf
    sed -i '/^channel=.*/c\channel='"${channel_number}" $hostapd_conf

    # restart hostapd
    sudo sh $hostapd_restart
    clear

    # if SSID is hidden then send a request probe request
    if [ public_broadcast = " False" ]; then 
      sudo iwlist $wifi_interface scan essid "$dynamic_ssid_3"
    fi
    
    echo "Wi-Fi Honeypot is broadcasting \"""${dynamic_ssid_3}\"""

"
    echo "Device \"""$echo_mac\""" is attempting to connect

"

    # escalate mac logging
    echo '' >> $threat_log
    echo $echo_mac >> $threat_log
    echo '' >> $threat_log
    sort -u $threat_log -o $threat_log

    if grep -q ":" $mac_log; then
      echo '
- - - - - - - -
Logged Devices
- - - - - - - -
'
      cat $mac_log
      echo '

'
    fi

    # if SSID is hidden then send a request probe request
    if [ public_broadcast = " False" ]; then 
      sudo iwlist $wifi_interface scan essid "$dynamic_ssid_3"
    fi
    
    # broadcast time (in seconds)
    sleep $dynamic_ssid_3__time

    # clear the syslog before the next pass
    sudo sh $clear_syslog




  #
  # DEVICE IS CONSIDERED A THREAT
  #

  elif grep associated $syslog && grep $echo_mac $mac_log && grep $echo_mac $mac_log_2 && grep $echo_mac $threat_log && ! grep $echo_mac $in_jail && grep -q "$default_ssid" $hostapd_conf; then

    echo "Threat device $echo_mac is trying to connect"

    ## Update hostapd conf
    # ! MAC inserted into SSID
    if sanitize_mac=$(echo "$echo_mac" | grep -Eio '\b([[:xdigit:]]{1,2}[:-]){5}[[:xdigit:]]{1,2}\b'); then
      # mac IS sanitized - (! MAC is in SSID)
    sed -i '/^ssid=.*/c\ssid='"${dynamic_ssid_4__before_mac} ${echo_mac}" $hostapd_conf
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

    # if SSID is hidden then send a request probe request
    if [ public_broadcast = " False" ]; then 
      grep_ssid=$(grep -Po '(?<=^ssid=).*' $hostapd_conf | tr -d \'\")
      sudo iwlist $wifi_interface scan essid "$grep_ssid"
    fi
    
    if sanitize_mac=$(echo "$echo_mac" | grep -Eio '\b([[:xdigit:]]{1,2}[:-]){5}[[:xdigit:]]{1,2}\b'); then
      # mac IS sanitized - (! MAC is in OSD)
      echo "Wi-Fi Honeypot is broadcasting \"""${dynamic_ssid_4__before_mac} ${echo_mac}\"""

"
      echo "Device \"""$echo_mac\""" is attempting to connect

"
    else
      # mac NOT sanitized
      echo "Wi-Fi Honeypot is broadcasting \"""${dynamic_ssid__not_sanitized}\"""

"
      echo "Device \"""$echo_mac\""" is attempting to connect with a non sanitized bssid

"
    fi


    # escalate mac logging
    echo '' >> $in_jail
    echo $echo_mac >> $in_jail
    echo '' >> $in_jail
    sort -u $in_jail -o $in_jail

    if grep -q ":" $mac_log; then
      echo '
- - - - - - - -
Logged Devices
- - - - - - - -
'
      cat $mac_log
      echo '

'
    fi

    # if SSID is hidden then send a request probe request
    if [ public_broadcast = " False" ]; then 
      grep_ssid=$(grep -Po '(?<=^ssid=).*' $hostapd_conf | tr -d \'\")
      sudo iwlist $wifi_interface scan essid "$grep_ssid"
    fi
    
    # broadcast time (in seconds)
    sleep $dynamic_ssid_4__time

    # clear the syslog before the next pass
    sudo sh $clear_syslog


  fi #/Dynamic SSID Escalated Responses




  # - - - - - - - - -
  # DEVICE IS IN JAIL
  # - - - - - - - - -

  if grep associated $syslog && grep $echo_mac $mac_log && grep $echo_mac $mac_log_2 && grep $echo_mac $threat_log && grep $echo_mac $in_jail && grep -q "$default_ssid" $hostapd_conf; then

    echo "Jailed device $echo_mac is trying to connect"
    jail_ssid=$(printf "$jail_ssid_1\n$jail_ssid_2\n$jail_ssid_3\n$jail_ssid_4\n$jail_ssid_5\n$jail_ssid_6\n$jail_ssid_7\n$jail_ssid_8\n$jail_ssid_9\n$jail_ssid_10\n" | shuf -n1)
    ## Update hostapd conf
    sed -i '/^ssid=.*/c\ssid='"${jail_ssid}" $hostapd_conf
    sed -i '/^bssid=.*/c\bssid='"${random_bssid}" $hostapd_conf
    sed -i '/^ignore_broadcast_ssid=.*/c\ignore_broadcast_ssid='"${broadcast_option}" $hostapd_conf
    sed -i '/^channel=.*/c\channel='"${channel_number}" $hostapd_conf

    # restart hostapd
    sudo sh $hostapd_restart
    clear

    # if SSID is hidden then send a request probe request
    if [ public_broadcast = " False" ]; then 
      grep_ssid=$(grep -Po '(?<=^ssid=).*' $hostapd_conf | tr -d \'\")
      sudo iwlist $wifi_interface scan essid "$grep_ssid"
    fi
    
    echo "Wi-Fi Honeypot is broadcasting \"""${jail_ssid}\"""

"
    echo "Jailed device \"""$echo_mac\""" is trying to connect

"

    if grep -q ":" $mac_log; then
      echo '
- - - - - - - -
Logged Devices
- - - - - - - -
'
      cat $mac_log
      echo '

'
    fi

    # if SSID is hidden then send a request probe request
    if [ public_broadcast = " False" ]; then 
      grep_ssid=$(grep -Po '(?<=^ssid=).*' $hostapd_conf | tr -d \'\")
      sudo iwlist $wifi_interface scan essid "$grep_ssid"
    fi
    
    # broadcast time (in seconds)
    sleep $jailed_ssid__time

    # clear the syslog
    sudo sh $clear_syslog


  fi #/DEVICE IS IN JAIL




done #/Infinite Loop
