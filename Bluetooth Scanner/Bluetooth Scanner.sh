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
#  scan for avaliable Bluetooth Devices and log MAC and Nameto file
#

# set terminal title
printf "\e]2;Local Bluetooth Scanner\a"

# change working directory
cd ~/Desktop

# log file name
log_file="Bluetooth Devices"

# generate log file
touch "$log_file"

# screen formatting
magenta_txt="\e[95m"; bold_txt=$(tput bold); reset_txt=$(tput sgr0)

# screen first run text
echo "Scanning Bluetooth Devices..."

# hide screen cursor
tput civis

# infinite loop
while true
do

  # count log enteries
  log_count=$(wc -l < "$log_file")

  # scan bluetooth devices and log to file
  hcitool scan >> "$log_file"

  # remove leading white spaces from log file
  sed -i "s/^[ \t]*//" "$log_file"

  # remove duplicate lines from log file
  perl -i -ne 'print if ! $x{$_}++' "$log_file"

  # delete empty lines from log file
  sed -i '/^$/d'  "$log_file"

  # remove unwanted entries from log file
  sed -i '/Scanning/d' "$log_file"

  # display log file on screen
  clear
  echo -e "${bold_txt}${magenta_txt}- - - - - - - - - - - - - - - -\nScanning For Bluetooth Devices\n- - - - - - - - - - - - - - - -\n${reset_txt}${bold_txt}"
  cat "$log_file"

  # "play" beep when new log entry
  if dpkg -l | grep -E '^ii' | grep -q "sox"; then
    new_count=$(wc -l < "$log_file")
    if [ "$new_count" -gt "$log_count" ]; then
      play -q -n synth 0.1 sin 880 || echo -e "\a"; sleep 1; play -q -n synth 0.1 sin 880 || echo -e "\a"; sleep 1; play -q -n synth 0.1 sin 880 || echo -e "\a"; sleep 2; play -q -n synth 0.1 sin 880 || echo -e "\a"; sleep 1; play -q -n synth 0.1 sin 880 || echo -e "\a"; sleep 1; play -q -n synth 0.1 sin 880 || echo -e "\a"
    fi
  fi

  # display on screen number of logged bluetooth devices
  if [ "$new_count" = 1 ]; then
    echo -e "\n${bold_txt}${magenta_txt}$((${new_count})) Bluetooth Device${reset_txt}"
  fi
  if [ "$new_count" -gt 1 ]; then
    echo -e "\n${bold_txt}${magenta_txt}$((${new_count})) Bluetooth Devices${reset_txt}"
  fi

  # slow the script down a bit
  sleep 30

done

echo "Something went wrong..."
sleep 5
exit
