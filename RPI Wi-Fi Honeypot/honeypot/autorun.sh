#!/bin/sh
# rc.local exit trap - boot with USB plugged into RPI to regain terminal access
if sudo fdisk -l | grep /dev/sda1; then
exit 0
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
#  Project:  Dynamic Wi-Fi Honeypot 4RPI3
#                 -  Honeypot Autorun Script
#
#  Version:      Proprietary, not authorized for release, viewing or publication
#  Author:       Brett Peters, 2017. All rights reserved
#  Contact:      asylum119@hotmail.com
#
#
#  DESCRIPTION
#
#  Use the RPI3 onboard Wi-Fi interface to create
#  a single AP that scans the syslog for connection
#  attempts, then when spotted dynamically change
#  the SSID Name and log the MAC trying to connect
#
#  Several script variations have been added, and by
#  default this script randomly selects one to load
#  on machine boot, boot is triggered from inside each
#  supplied script after a user set amount of script
#  loop passes. To load a single script only, follow
#  the comments located below
#
#
#  NOTES
#
#  rc.local with an infinite loop will lock the user out
#  of terminal so an exit trap has been set, boot the RPI
#  with a USB plugged in to regain terminal functionality
#
#  Warning! '/var/log/syslog' gets cleared out due to the
#  RPI not having an onboard clock, makes checking log entry
#  times difficult. This may affect you if adding the Honeypot
#  to a NON single project RPI or not using on a RPI
#
#  Honeypot has been designed for use with the RPI3s onboard
#  Wi-Fi, RPI2 users with Wi-Fi dongles will need to add a
#  driver path and possibly change the wlan0 value inside
#  each of the Honeypot scripts to suit, each has comments
#  which can be found by searching the scripts for 'RPI2'
#
#
#  REQUIREMENTS
#
#  * RPI2
#  * GNU/Linux
#  * HostAPD
#  * DNSmasq
#  * Edit conf files (see readme file)
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - -



# - - - - - - - - -
#  SCRIPT SETTINGS
# - - - - - - - - -


#
#  RUN A SCRIPT AT RANDOM
#
#  ! This setting is "True" by default allowing the Wi-Fi Honeypot
#  to select a script at random when loaded, change to "False" if
#  you want to run a single script.
#
#  ! If "False" is set, the single script you wish to load will need
#  to be uncommented in the "MANUALLY LOAD A SCRIPT" section.
#

   random_script_load="False"


																																															if [ $random_script_load = 'False' ]; then

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#  MANUALLY LOAD A SCRIPT
#
#  ! make sure ^ 'random_script_load=' is set to "False"
#  ! uncomment the single script below that you wish to load
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  #
  #  Honeypot Script
  #
  #  ! escalated SSID response per device attempting to connect, then rebroadcast the default SSID
  #

    # sudo sh /etc/honeypot/script/./honeypot.sh


  #
  #  Hacking Challenge Script
  #
  #  ! random SSID response when a connection attempt is detected, then rebroadcast the default SSID
  #

     sudo sh /etc/honeypot/script/./hacker-challenge.sh



  #
  #  Extraterrestrial Welcome Beacon Script
  #
  #  ! rotates through several predefined SSID responses when a connection attempt is detected, then rebroadcast the default SSID
  #

    # sudo sh /etc/honeypot/script/./alien-welcome-beacon.sh



  #
  #  Randomized Trailing Digits Script
  #
  #  ! this SSID name has trailing digits that randomize when a connection attempt is made
  #

    # sudo sh randomized-trailing-digits.sh

																																															fi



# - S - T - A - R - T - - T - H - E - - S - C - R - I - P - T - - >


# if user is NOT manually loading a particular script then load one at random
if [ $random_script_load = "True" ]; then
  # script paths
  script_1="/etc/honeypot/script/./honeypot.sh"
  script_2="/etc/honeypot/script/./hacker-challenge.sh"
  script_3="/etc/honeypot/script/./alien-welcome-beacon.sh"
  script_4="/etc/honeypot/script/./randomized-trailing-digits.sh"
  # randomize script load
  random_script=$(printf "$script_1\n$script_2\n$script_3\n$script_4\n" | shuf -n1)
  # load the script
  sudo sh $random_script
fi
