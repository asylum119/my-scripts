#!/bin/sh
# rc.local exit trap - boot with USB plugged into RPI to regain terminal access
if sudo fdisk -l | grep /dev/sda1; then
exit 0
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
#  Project:      Dynamic Wi-Fi Honeypot 4RPI3
#                 -  Wi-Fi Hacking Challenge Script
#
#  Version:      Proof Of Concept
#  Author:       Brett Peters, 2017
#  Contact:      asylum119@hotmail.com
#
#
#  DESCRIPTION
#
#  Use the RPI3s onboard Wi-Fi interface to broadcast a
#  single Dynamic Wi-Fi AP, then update the SSID with a
#  random response upon each connection attempt.
#
#  This script dynamically updates the broadcast SSID with
#  a predefined response, at random, when a connection attempt
#  is made on the default SSID. The SSID response falls back to
#  the default SSID after the broadcast response time is reached.
#
#  This particular script is a hacking challenge to detect threat
#  devices pen testing Wi-Fi allowing router admins to block threat
#  mac addresses, or simply just an SSID to have some fun with.
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

   default_ssid="Can't Hack This"



#
#  Welcome SSID Name
#
#  ! This will broadcast when a new device is attempting to connect for the first time only.
#

   welcome_ssid="Welcome! Rename The SSID To Win"




  #
  #  Broadcast Time
  #
  #  ! Set the broadcast time for the dynamic SSID responses,
  #  once the time limit has been reached the honeypot will
  #  go back to broadcasting the default Wi-Fi name.
  #
  #  ! HostAPD needs time to restart and devices also need
  #  some time to update the new Wi-Fi name. (keep above 20)
  #

     broadcast_time="120"




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
echo "\033]0;Wi-Fi Honeypot - Hacker Challenge\a"
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
# ! Warning! the hostapd config file does not like some situations, refer to
# @https://w1.fi/cgit/hostap/plain/hostapd/hostapd.conf


# Write Defaults To The HostAPD Configuration File
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

# hostapd is dead
if sudo service hostapd | grep dead; then
  sudo sh $hostapd_restart
fi

# hostapd is exited
if sudo service hostapd status | grep exited; then
  sudo service hostapd force-reload
fi

# OSD
echo '	 Wi-Fi Honeypot Is Loading...'
if ! sudo fdisk -l | grep dev/sda1; then
  echo  '	 Insert USB and reboot to regain terminal access'
fi


# Restart HostAPD
# ! HostAPD would sometimes fail to broadcast on boot
sudo sh $hostapd_restart
clear

# OSD
echo "Wi-Fi Honeypot is broadcasting \"""${default_ssid}\"""

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



# Infinite Loop
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



  if ! grep associated $syslog && ! grep -q "$default_ssid" $hostapd_conf; then

    # Update hostapd conf
    sed -i '/^ssid=.*/c\ssid='"${default_ssid}" $hostapd_conf
    sed -i '/^bssid=.*/c\bssid='"${random_bssid}" $hostapd_conf
    sed -i '/^ignore_broadcast_ssid=.*/c\ignore_broadcast_ssid='"${broadcast_option}" $hostapd_conf
    sed -i '/^channel=.*/c\channel='"${channel_number}" $hostapd_conf

    # restart hostapd
    sudo sh $hostapd_restart
    clear

    # OSD
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


  fi #/DEFAULT SSID - FALLBACK




  # - - - - - - - - - -
  # NEW DEVICE DETECTED
  # - - - - - - - - - -



  if grep associated $syslog && ! grep $echo_mac $master_mac && grep -q "$default_ssid" $hostapd_conf; then

    # OSD
    echo "Device $echo_mac is trying to connect"

    # log the mac address (singular) that tried to connect
    echo '' >> $master_mac
    echo $echo_mac >> $master_mac
    echo '' >> $master_mac
    sort -u $master_mac -o $master_mac


    #
    # Dynamic SSID
    #

    # Update hostapd conf
    sed -i '/^ssid=.*/c\ssid='"${welcome_ssid}" $hostapd_conf
    sed -i '/^bssid=.*/c\bssid='"${random_bssid}" $hostapd_conf
    sed -i '/^ignore_broadcast_ssid=.*/c\ignore_broadcast_ssid='"${broadcast_option}" $hostapd_conf
    sed -i '/^channel=.*/c\channel='"${channel_number}" $hostapd_conf

    # restart hostapd
    sudo sh $hostapd_restart
    clear

    # OSD
    echo "Wi-Fi Honeypot is broadcasting \"""${welcome_ssid}\"""

"
    echo "Device \"""$echo_mac\""" is attempting to connect

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

    # clear the syslog
    sudo sh $clear_syslog


  fi #/NEW DEVICE DETECTED




  # - - - - - - - - - - - - - -
  # CONNECTION ATTEMPT DETECTED
  # - - - - - - - - - - - - - -



  if grep associated $syslog && grep -q $echo_mac $master_mac && grep -q "$default_ssid" $hostapd_conf; then


    # OSD
    echo "Device $echo_mac is trying to connect"



    #
    #  Random SSID Partial Responses
    #
    #  ! These are some partial responses that are randomized before getting inserted into the final SSID response
    #

    social_peg=$(printf "Script Kiddie\nNoob\nHacker\nBrony\n" | shuf -n1)
    hacked_method=$(printf "Brute Forced\nPen Tested\nHacked\n" | shuf -n1)
    hacking_method=$(printf "Pen Testing\nHacking\nBrute Forcing\n" | shuf -n1)
    hacker_type=$(printf "Wardrivers\nHackers\nPen Testers\n" | shuf -n1)
    tried_this=$(printf "Terminal\nKali Linux\nGNU Linux\nMAC Targeting\nShell Script" | shuf -n1)
    better_suited=$(printf "Poetry\nKnitting\nDisk Golf\nRC Planes\nThe Beach\na YoYo\nMacrame\nSudoku\n" | shuf -n1)
    negative_exp=$(printf "complicated\ndifficult\nstrenuous\npainful\n" | shuf -n1)
    search_term=$(printf "WPA2 Pen Test Script\nKali Linux WPA2 Help\nHow To Pen Test WPA2\nWPA2 Hacking For Noobs\nHack Neighbors Wi-Fi\nHow To Wardrive\nWPA2 Brute Force\nKali IRC Channel\ncloud GPU cracking\n" | shuf -n1)
    need_this=$(printf "more experience\nnetworking advice\nscript knowledge\nLinux Tutoring\nto give up\nhacking advice\n" | shuf -n1)
    hint=$(printf "Is Nine Characters\nHas Eight Numbers\nHas One Special Char\nis 123_56_ _ _\n" | shuf -n1)
    do_this=$(printf "unlock It For You\nYell The Pass Out\nMake The Pass Easier\nChange WPA2 To WPA1\n" | shuf -n1)
    social=$(printf "MySpace\nMinecraft\nTumblr\nWattpad\nAsk.Fm\nOmegle\nBebo\nFlickr\nWhisper\nKik\nTagged\nTinder\nPopjam\niFunny\nQuotev\n9GAG\nImzy\n" | shuf -n1)
    game=$(printf "Y_U _UC_ AT THI_\nC_N'_ H_CK _HIS\nNO CH_NCE B_UV\nP_OPS FO_ T_YING\n" | shuf -n1)
    movie_quote=$(printf "May the Force be with you\nYou're gonna need a bigger boat\nI am your father\nBond. James Bond\nTo infinity and beyond!\nShaken, not stirred\nIf you build it, he will come\nThe Dude abides\nGood morning, Vietnam!\nWax on, wax off\nNobody puts Baby in a corner\nChewie, we're home\nA martini. Shaken, not stirred\nThis one time, at band camp...\nBye, Felicia\nHere's looking at you, kid\nGo ahead, make my day\nYou talking to me ?\nShow me the money!\nYou can't handle the truth!\nI'll have what she's having\nI'll be back\nI see dead people\nStella! Hey, Stella!\nIt's alive! It's alive!\nHouston, we have a problem\nYou had me at hello\nThere's no crying in baseball!\nSay hello to my little friend\nElementary, my dear Watson\nNo wire hangers, ever!\nForget it, Jake, it's Chinatown\nHasta la vista\nbaby\nToga! Toga!\nYo, Adrian!\n" | shuf -n1)


    #
    #  Random SSID Responses
    #
    #  ! These are the default SSID responses that are picked at random after inserting a randomized partial response
    #  ! Make sure that Responses + Partial Responses when combined do not exceed the SSID broadcast character limit of 31

    dynamic_ssid_1="$social_peg Detected On Wi-Fi"        # Script Kiddie | Noob | Hacker | Brony
    dynamic_ssid_2="Wi-Fi is being $hacked_method"        # Brute Forced | Pen Tested | Hacked
    dynamic_ssid_3="Someone is $hacking_method Wi-Fi"     # Pen Testing | Hacking | Brute Forcing
    dynamic_ssid_4="You Make $hacker_type Look Bad"       # Wardrivers | Hackers | Pen Testers
    dynamic_ssid_5="Have you tried $tried_this ?"         # Terminal | Kali Linux | GNU Linux | MAC Targeting | Shell Script
    dynamic_ssid_6="$better_suited might suit you better" # Poetry | Knitting | Disk Golf | RC Planes | The Beach | A YoYo | Macrame | Sodoku
    dynamic_ssid_7="You make this look $negative_exp"     # complicated | difficult | strenuous | painful
    dynamic_ssid_8="Google - $search_term"                # WPA2 Pen Test Script | Kali Lunux WPA2 Help | How To Pen Test WPA2 | WPA2 Hacking For Noobs | Hack Neighbors Wi-Fi | How To Wardrive | WPA Brute Force Script | Kali IRC Channel | cloud GPU cracking
    dynamic_ssid_9="You need $need_this"                  # more experience | networking advice | script knowledge | Linux Tutoring | to give up | hacking advice 
    dynamic_ssid_10="HINT: Pass $hint"                    # Is Nine Characters | Has Eight Numbers | Has One Special Char | is 123_56_ _ _
    dynamic_ssid_11="Should I $do_this ?"                 # unlock It For You | Yell The Pass Out | Make The Pass Easier | Change WPA2 To WPA1
    dynamic_ssid_12="You must need net for $social"       # MySpace | Minecraft | Tumblr | Wattpad | Ask.Fm | Omegle | Bebo | Flickr | Whisper | Kik | Tagged | Tinder | Popjam | iFunny | Quotev | 9GAG | Imzy 
    dynamic_ssid_13="Hangman: $game"                      # Y_U _UC_ AT THI_ | C_N'_ H_CK _HIS | NO CH_NCE B_UV | P_OPS FO_ T_YING
    dynamic_ssid_14="$movie_quote"                        # May the Force be with you | You're gonna need a bigger boat | I am your father | Bond. James Bond | To infinity and beyond! | Shaken, not stirred | If you build it, he will come | The Dude abides | Good morning, Vietnam! | Wax on, wax off | Nobody puts Baby in a corner | Chewie, we're home | A martini. Shaken, not stirred | This one time, at band camp... | Bye, Felicia | Here's looking at you, kid | Go ahead, make my day | You talking to me ? | Show me the money! | You can't handle the truth! | I'll have what she's having | I'll be back | I see dead people | Stella! Hey, Stella! | It's alive! It's alive! | Houston, we have a problem | You had me at hello | There's no crying in baseball! | Say hello to my little friend | Elementary, my dear Watson | No wire hangers, ever! | Forget it, Jake, it's Chinatown | Hasta la vista, baby | Toga! Toga! | Yo, Adrian!


    # final singular random SSID output
    random_ssid=$(printf "$dynamic_ssid_1\n$dynamic_ssid_2\n$dynamic_ssid_3\n$dynamic_ssid_4\n$dynamic_ssid_5\n$dynamic_ssid_6\n$dynamic_ssid_7\n$dynamic_ssid_8\n$dynamic_ssid_9\n$dynamic_ssid_10\n$dynamic_ssid_11\n$dynamic_ssid_12\n$dynamic_ssid_13\n$dynamic_ssid_1\n" | shuf -n1)



    #
    # Dynamic SSID
    #

    # Update hostapd conf
    sed -i '/^ssid=.*/c\ssid='"${random_ssid}" $hostapd_conf
    sed -i '/^bssid=.*/c\bssid='"${random_bssid}" $hostapd_conf
    sed -i '/^ignore_broadcast_ssid=.*/c\ignore_broadcast_ssid='"${broadcast_option}" $hostapd_conf
    sed -i '/^channel=.*/c\channel='"${channel_number}" $hostapd_conf

    # restart hostapd
    sudo sh $hostapd_restart
    clear

    # OSD
    echo "Wi-Fi Honeypot is broadcasting \"""${random_ssid}\"""

"
    echo "Device \"""$echo_mac\""" is attempting to connect

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

    # clear the syslog
    sudo sh $clear_syslog


  fi #/CONNECTION ATTEMPT DETECTED




done #/Infinite Loop
