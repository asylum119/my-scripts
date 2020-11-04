#!/bin/bash

   #######    Shell script by Brett Peters    #######
   #######     - asylum119@hotmail.com        #######
   #######                                    #######
#############                              #############
 ###########                                ###########
  #########                                  #########
   #######                                    #######
    #####                                      #####
     ###                                        ###
      #                                          #
#
#  scan for avaliable Wi-Fi Networks and log BSSID and SSID to file
#  - this script lets me know if someone has tried hacking a Wi-Fi honeypot (logs the honeypots dynamic SSID changes)
#  - this will also eventually log all nearby hidden networks if run long enough (SSIDs were never designed to be hiden)
#

# set terminal title
printf "\e]2;Local Wi-Fi Scanner\a"

# change working directory
cd ~/Desktop

# log file name
log_file="Wi-Fi Networks"

# generate log file
touch "$log_file"

# screen formatting
magenta_txt="\e[95m"; bold_txt=$(tput bold); reset_txt=$(tput sgr0)

# screen first run text
echo "Scanning Wi-Fi Networks..."

# hide screen cursor
tput civis

# infinite loop
while true
do

  # count log enteries
  log_count=$(wc -l < "$log_file")

  # scan Wi-Fi networks and log BSSIDs and SSIDs to file
  nmcli -f BSSID,SSID dev wifi >> "$log_file"

  # remove trailing white spaces from log file
  sed -i 's/[ \t]*$//' "$log_file"

  # remove duplicate lines from log file
  perl -i -ne 'print if ! $x{$_}++' "$log_file"

  # delete empty lines from log file
  sed -i '/^$/d'  "$log_file"

  # remove unwanted entries from log file
  #sed -i '/SSID/d' "$log_file"

  # display log file on screen
  clear
  echo -e "${bold_txt}${magenta_txt}- - - - - - - - - - - - - - - - -\nScanning For Local Wi-Fi Networks\n- - - - - - - - - - - - - - - - -\n${reset_txt}${bold_txt}"
  cat "$log_file"

  # "play" beep when new log entry
  if dpkg -l | grep -E '^ii' | grep -q "sox"; then
    new_count=$(wc -l < "$log_file")
    if [ "$new_count" -gt "$log_count" ]; then
      play -q -n synth 0.1 sin 880 || echo -e "\a"; sleep 1; play -q -n synth 0.1 sin 880 || echo -e "\a"; sleep 1; play -q -n synth 0.1 sin 880 || echo -e "\a"; sleep 2; play -q -n synth 0.1 sin 880 || echo -e "\a"; sleep 1; play -q -n synth 0.1 sin 880 || echo -e "\a"; sleep 1; play -q -n synth 0.1 sin 880 || echo -e "\a"
    fi
  fi

  # display on screen number of logged Wi-Fi networks
  if [ "$new_count" = 1 ]; then
    echo -e "\n${bold_txt}${magenta_txt}$((${new_count} -1)) Wi-Fi Network${reset_txt}"
  fi
  if [ "$new_count" -gt 1 ]; then
    echo -e "\n${bold_txt}${magenta_txt}$((${new_count} -1)) Wi-Fi Networks${reset_txt}"
  fi

  # slow the script down a bit
  sleep 30

done

echo "Something went wrong..."
sleep 5
exit
