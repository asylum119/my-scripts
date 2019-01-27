#!/bin/bash
# WARNING! This script is for advanced users and released for peer review only. it can damage expensive hardware, cause data loss, fire, power outage, security breaches and other odd events. Only deploy if you do a full code audit and accept full responsibility for what happens next. Your System, Your Hardware... Your responsibility.

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# AMD-GPU-PRO GPU OVERHEAT PROTECTION + OTHER OPTIONS FOR MINERS 4 Ubuntu 16.0.4 | Alfa V0.0.1
#
# Found out fairly quickly as a new miner that some things just don't happen with Ubuntu, GPU fan
# speeds being one. This script does what I need / want, as I currently only have AMD RX GPUs this
# script is AMD RX only. WARNING! hardware overheating is no joke, do not deploy this script unless
# YOU do a code audit and accept full responsibility.WARNING! the Ubuntu user is granted sudoers
# (root) privileges for this script and is something to consider security wise before continuing.
#
#
# DEPENDENCIES: amdgpu-pro-fans.sh, graphics.pl, lm-sensors, festival, cmu_us_clb_arctic-0.95-release
# - ^ are installed / downloaded by the script on first load, if you give consent
# - manually install AMD-GPU-PRO Driver (this should be part of your initial OS set up anyways)
#
#
# UNINSTALL
# sudo apt-get remove --purge festival     # only do this if festival was not already installed
# sudo apt-get remove --purge lm-sensors   # only do this if sensors was not already installed
# cd ~; rm amdgpu-pro-fans.sh              # remove third party GPU fan speeds script
# cd ~; rm graphics.pl                     # remove third party GPU overclocking script
#
#
#
# BASH SCRIPT CREDIT
# Brett Peters, asylum119 - github.com/asylum119
#
#
# THIRD PARTY CREDITS
# amdgpu-pro-fans.sh
# Tim Garrity, uaktags - github.com/uaktags/amdgpu-pro-fans
# - forked from Michael, DominiLux - github.com/DominiLux/amdgpu-pro-fans (Added single GPU functionality)
# License: raw.githubusercontent.com/DominiLux/amdgpu-pro-fans/master/LICENSE
#
# graphics.pl
# Zenekell - github.com/zenekell/graphics.pl
# License: raw.githubusercontent.com/zenekell/graphics.pl/master/LICENSE
#
# cmu_us_clb_arctic-0.95-release
# Carnegie Mellon University - http://www.speech.cs.cmu.edu/cmu_arctic/packed/cmu_us_clb_arctic-0.95-release.tar.bz2
# License: speech.cs.cmu.edu/cmu_arctic/cmu_us_clb_arctic/COPYING
#
#
# GENERAL BASH SNIPPET CREDITS
# user confirmation
# - user389850 - stackoverflow.com/a/3232044
#
# convert number into words
# - Glenn Jackman - unix.stackexchange.com/a/413475
#
# clear PageCache, dentries
# - Riyaj Shamsudeen, blog.pythian.com/performance-tuning-hugepages-in-linux
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


#
# SET THE TEMPERATURE LIMITS (°C) FOR CPU, GPU AND AIO
# - the computer should suspend when a temp setting is reached.
# ! WARNING: these values should be a safe operating temp to limit critical hardware failure.
#

  # MAX GPU Temp
  # 69 for normal algo - 79 for turtle algo (Pico)
  shutdown_GPU_temp="79"


  # MAX CPU Temp
  # 69 for normal algo - 79 for turtle algo (Pico)
  shutdown_CPU_temp="79"


  # MAX AIO Temp
  # 69 for normal algo - 79 for turtle algo (Pico)
  shutdown_AIO_temp="79"



#
# SET THE GPU NAMES
# - in terminal type "sensors" and enter all of the GPU names you find here
# - set any non used variables to "False", support for up to 8 AMD RX GPUs
#

  # GPU Names
  GPU_name_01="amdgpu-pci-4100"
  GPU_name_02="amdgpu-pci-0a00"
  GPU_name_03="False"
  GPU_name_04="False"
  GPU_name_05="False"
  GPU_name_06="False"
  GPU_name_07="False"
  GPU_name_08="False"


#
# SET THE CPU NAME
# - in terminal type "sensors" and enter the CPU name you find here
# - set to "False" if you do not wish to monitor the CPU for high temps
#

  # CPU Name
  CPU_name="k10temp-pci-00c3"



    #
    # set the AIO (water cooler) name
    # - in terminal type "sensors" and enter the AIO (water cooler) name you find here
    # - set to "False" if you do not have a CPU water cooler or if you do not wish to monitor AIO
    #

    # AIO (water cooler) name
    AIO_name="k10temp-pci-00cb"





#
# ALLOW SCRIPT TO RUN AS ROOT (SUDO)
# - this is needed for the script to operate properly
# - set to "False" if not giving sudo permissions to the script (not recommended)
# - WARNING! do not use this script unless you have no security concerns regarding your miner
#

  # run script as root
  sudoers="True"



    #
    # SET THE OVERHEAT SUSPEND TIME
    # - set the amount of time in seconds to resume after a computer shutdown caused by high hardware temperatures
    # - not recommended to go under 1Hr (we want to limit multiple shutdowns on hot days to protect expensive hardware)
    #

    # suspend time
    suspend_time="10800" # 1Hr "3600", 2Hr "7200", 3Hr "10800", 4Hr "14400"


    #
    # SET THE GPU FREQUENCY IN MHz
    # - WARNING! only tested on RX580s
    # - this is good for underclocking AMD RX GPUs using the AMD-GPU-PRO Driver
    # - set to "False" (default) to not alter the GPU frequency
    #

    # GPU frequency
    gpuClock_frequency="1340" # "300", "600", "900", "1145", "1215", "1257", "1300", "1340", "False"



    #
    # SET THE GPU MEMCLOCK FREQUENCY IN MHz
    # - WARNING! only tested on RX580s
    # - this is good for underclocking AMD RX GPUs using the AMD-GPU-PRO Driver
    # - set to "False" (default) to not alter the memclock frequency
    #

    # memclock frequency
    memClock_frequency="2000" # "300", "1000", "2000", "False"



#
# REBOOT THE SYSTEM
# - enabling this will reboot the system (handy if Ubuntu upgrades packages and requires a reboot)
# - this can be set to "False" if your Ubuntu system does not automatically update packages or security updates
# - set to "True" to enable | "False" to disable
#

  # reboot if Ubuntu needs it
  system_reboot="True"



#
# ENABLE SPEECH
# - uses festival with a womans voice for vocal updates
# - good if you have a speaker and rarely power on a monitor, but also would like to be updated
# - set to "True" to enable | "False" to disable
#

  # clear caches
  enable_speech="True"



  #
  # VOLUME LIMITING
  # sets the pulse volume to 40% at 8am and 30% at 8pm
  # - I leave the door open on hot nights and the neighbor goes ham at the speech updates
  # - set to "True" to enable | "False" to disable
  #

    # volume limiting
    volume_limiting="True"

      # am volume percentages
      # ! must be a two digit number followed by the % sign (eg "40%")
      am_volume="38%"

      # pm volume percentages
      # ! must be a two digit number followed by the % sign (eg "30%")
      pm_volume="27%"



#
# CLEAR THE CACHES
# EXPERIMENTAL: see if can stabilize the CPU hash rate over time (https://blog.pythian.com/performance-tuning-hugepages-in-linux/)
# - clear PageCache, dentries and inodes once a day
# - set to "True" to enable | "False" to disable
#

  # clear caches
  clear_caches="True"






# - - S - T - A - R - T - - T - H - E - - S - C - R - I - P - T - - - >



######
######	STARTUP ENVIRONMENT
######	- before we run the script
######

# script location
SCRIPT="$0"

# Ubuntu 16 check
Ubuntu_Version=$(lsb_release -d | awk {'print $3'} | cut -c 1-2)
if [ "$Ubuntu_Version" != "16" ]; then
  clear
  echo "This script only supports Ubuntu 16"
  sleep 2
  echo "Goodbye"
  sleep 2
  exit 0
fi

# title
printf "\e]2;Hardware Overheat Protection\a"

# responsive screen size
default_screen_height="18"
if [ ! -z "$GPU_name_01" ] && [ "${GPU_name_01,,}" != "false" ]; then gpu_height1="1"; else gpu_height1="0"; fi
if [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ]; then gpu_height2="1"; else gpu_height2="0"; fi
if [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ]; then gpu_height3="1"; else gpu_height2="0"; fi
if [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ]; then gpu_height4="1"; else gpu_height2="0"; fi
if [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ]; then gpu_height5="1"; else gpu_height2="0"; fi
if [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ]; then gpu_height6="1"; else gpu_height2="0"; fi
if [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ]; then gpu_height7="1"; else gpu_height2="0"; fi
if [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ]; then gpu_height8="1"; else gpu_height2="0"; fi
if [ -z "$clear_caches" ] && [ "${clear_caches,,}" != "false" ]; then cache_height="1"; else cache_height="0"; fi
new_screen_height=$((default_screen_height + cache_height + gpu_height1 + gpu_height2 + gpu_height3 + gpu_height4 + gpu_height5 + gpu_height6 + gpu_height7 + gpu_height8 + cache_height))
resize -s $new_screen_height 50

# working directory
cd ~

# create sudoers file
if [ "${sudoers,,}" = "true" ] && [ ! -f "/etc/sudoers.d/$USER" ]; then
  clear
  echo -e "script needs to grant current user sudo for the script\nWARNING! this is not for everyone, but also needed for automation.\n"

  # user confirm - create sudoers
  # user confirm - credit: user389850 - stackoverflow.com/a/3232044
  read -p "Run as root ? <y/N> " prompt
  if [[ $prompt =~ [yY](es)* ]]; then
    clear
    sudo touch "/etc/sudoers.d/$USER"
    sudo chmod 777 "/etc/sudoers.d/$USER"
    sudo echo "$USER ALL=(root) NOPASSWD: $SCRIPT" > "/etc/sudoers.d/$USER"
    sudo chmod 644 "/etc/sudoers.d/$USER"
    clear
    echo "\"""$USER\""" is now setup to run the script as root"
    sleep 2
    # script must now be run as "sudo /path/to/script"
  else
    clear; echo "root is needed for this script to continue"; sleep 5; echo "goodbye"; sleep 2; exit 0
  fi
fi

# install sensors
if [ "${sudoers,,}" = "true" ] && [ ! -d '/etc/sensors.d' ]; then
  clear
  echo -e "Script wants to install \"""lm-sensors\""" so script can get and use hardware info"

  # user confirm - install sensors
  # user confirm - credit: user389850 - stackoverflow.com/a/3232044
  read -p "Install Sensors ? <y/N> " prompt
  if [[ $prompt =~ [yY](es)* ]]; then
    clear
    echo -e "${Light_Green}Installing Sensors${Default}\n"
    sleep 2
    sudo apt-get install lm-sensors
    clear
  else
    clear; echo "lm-sensors must be installed for this script to continue"; sleep 5; echo "goodbye"; sleep 2; exit 0
  fi
fi

# wget - amdgpu-pro-fans.sh (now with individual GPU support)
if [ "${sudoers,,}" = "true" ] && [ ! -f 'amdgpu-pro-fans.sh' ]; then
  clear
  echo -e "Script wants to download \"""amdgpu-pro-fans.sh\""" for GPU fan support, forked from \"""github.com/DominiLux/amdgpu-pro-fans\""". LICENSE \"""raw.githubusercontent.com/DominiLux/amdgpu-pro-fans/master/LICENSE\""""

  # user confirm - download amdgpu-pro-fans.sh
  # user confirm - credit: user389850 - stackoverflow.com/a/3232044
  read -p "Download amdgpu-pro-fans.sh ? <y/N> " prompt
  if [[ $prompt =~ [yY](es)* ]]; then
    clear
    echo -e "${Light_Green}Downloading amdgpu-pro-fans${Default}\n"
    sleep 2
    wget "https://raw.githubusercontent.com/asylum119/amdgpu-pro-fans/master/amdgpu-pro-fans.sh"
    sudo -S chmod +x "amdgpu-pro-fans.sh"
    clear
  else
    clear; echo "amdgpu-pro-fans.sh must be downloaded for this script to continue"; sleep 5; echo "goodbye"; sleep 2; exit 0
  fi
fi

# wget - graphics.pl (amd-gpu-pro driver over/under clocking for rx gpu only)
if [ "${sudoers,,}" = "true" ] && [ ! -f 'graphics.pl' ]; then
  clear
  echo -e "Script wants to download \"""graphics.pl\""" for GPU underclocking support, forked from \"""github.com/zenekell/graphics.pl\""". LICENSE \"""raw.githubusercontent.com/zenekell/graphics.pl/master/LICENSE\""""

  # user confirm - download graphics.pl
  # user confirm - credit: user389850 - stackoverflow.com/a/3232044
  read -p "Download graphics.pl ? <y/N> " prompt
  if [[ $prompt =~ [yY](es)* ]]; then
    clear
    echo -e "${Light_Green}Downloading graphics.pl${Default}\n"
    sleep 2
    wget "https://raw.githubusercontent.com/asylum119/graphics.pl/master/graphics.pl"
    sudo -S chmod +x "graphics.pl"
    clear
  else
    clear; echo "amdgpu-pro-fans.sh must be downloaded for this script to continue"; sleep 5; echo "goodbye"; sleep 2; exit 0
  fi
fi

# Install Text To Speech - festival
if [ "${sudoers,,}" = "true" ] && [ ! -f "/etc/festival.scm" ]; then
  if [ ! -z "$enable_speech" ] && [ "${enable_speech,,}" = "true" ]; then
    clear
    echo -e "Script wants to install \"""festival\""" for text to speech support and download a voice from \"""speech.cs.cmu.edu/cmu_arctic/packed/cmu_us_clb_arctic-0.95-release.tar.bz2\""""

  # user confirm - install festival
  # user confirm - credit: user389850 - stackoverflow.com/a/3232044
  read -p "Install festival ? <y/N> " prompt
    if [[ $prompt =~ [yY](es)* ]]; then
      clear
      sudo apt-get install festival -y
      clear
      echo -e "${Light_Green}Upgrading Festival voice to Female${Default}\n"
      sleep 2
      cd "/usr/share/festival/voices/english/"
      sudo wget -c http://www.speech.cs.cmu.edu/cmu_arctic/packed/cmu_us_clb_arctic-0.95-release.tar.bz2
      sudo tar jxf cmu_us_clb_arctic-0.95-release.tar.bz2 
      sudo ln -s cmu_us_clb_arctic cmu_us_clb_arctic_clunits
      # Set The New Default Voice
      sudo chmod 777 /etc/festival.scm
      echo "
;; Set Default Voice
(set! voice_default 'voice_cmu_us_clb_arctic_clunits)" >> /etc/festival.scm
      # clean up
      sudo rm cmu_us_clb_arctic-0.95-release.tar.bz2
      cd ~
      clear
    else
      clear; echo "the script will continue without voice support"; sleep 2
    fi
  fi
fi

# osd - screen colors
Light_Cyan="\e[96m"; Default="\e[39m"; Light_Green="\e[92m"; Light_Yellow="\e[93m"; Light_Magenta="\e[95m"; Light_Gray="\e[37m"; Red="\e[31m"; Light_Blue="\e[94m";

# osd - screen font types
bold=$(tput bold); normal=$(tput sgr0)

# osd - shutdown_CPU_temp
if [ "${shutdown_CPU_temp,,}" != "false" ]; then
  CPU_user_setting="\n ${Light_Yellow}Max CPU Temp is set to ${Light_Gray}${shutdown_CPU_temp}.0°C"
else
  CPU_user_setting=""
fi

# osd - shutdown_GPU_temp
if [ "${shutdown_GPU_temp,,}" != "false" ]; then
  GPU_user_setting="\n ${Light_Green}Max GPU Temp is set to ${Light_Gray}${shutdown_GPU_temp}.0°C"
else
  GPU_user_setting=""
fi

# osd shutdown_AIO_temp
if [ "${shutdown_AIO_temp,,}" != "false" ]; then
  AIO_user_setting="\n ${Light_Magenta}Max AIO Temp is set to ${Light_Gray}${shutdown_AIO_temp}.0°C"
else
  AIO_user_setting=""
fi

# gpu check
if [ ! -z "$GPU_name_01" ] && [ "${GPU_name_01,,}" != "false" ] || [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ] || [ ! -z "$GPU_name_03" ] && [ "${GPU_name_03,,}" != "false" ] || [ ! -z "$GPU_name_04" ] && [ "${GPU_name_04,,}" != "false" ] || [ ! -z "$GPU_name_05" ] && [ "${GPU_name_05,,}" != "false" ] || [ ! -z "$GPU_name_06" ] && [ "${GPU_name_06,,}" != "false" ] || [ ! -z "$GPU_name_07" ] && [ "${GPU_name_07,,}" != "false" ] || [ ! -z "$GPU_name_08" ] && [ "${GPU_name_08,,}" != "false" ]; then
  clear
  echo "Script needs a GPU inputted"
  sleep 20
  exit 0
fi

# start gpu fans at 95% to avoid an initial high reading
if [ "${sudoers,,}" = "true" ]; then
  sudo -S "./amdgpu-pro-fans.sh" -s 95
  current_speed="95"
  if [ ! -z "$GPU_name_01" ] && [ "${GPU_name_01,,}" != "false" ]; then current_speed1="95"; else current_speed1="0"; fi
  if [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ]; then current_speed2="95"; else current_speed2="0"; fi
  if [ ! -z "$GPU_name_03" ] && [ "${GPU_name_03,,}" != "false" ]; then current_speed3="95"; else current_speed3="0"; fi
  if [ ! -z "$GPU_name_04" ] && [ "${GPU_name_04,,}" != "false" ]; then current_speed4="95"; else current_speed4="0"; fi
  if [ ! -z "$GPU_name_05" ] && [ "${GPU_name_05,,}" != "false" ]; then current_speed5="95"; else current_speed5="0"; fi
  if [ ! -z "$GPU_name_06" ] && [ "${GPU_name_06,,}" != "false" ]; then current_speed6="95"; else current_speed6="0"; fi
  if [ ! -z "$GPU_name_07" ] && [ "${GPU_name_07,,}" != "false" ]; then current_speed7="95"; else current_speed7="0"; fi
  if [ ! -z "$GPU_name_08" ] && [ "${GPU_name_08,,}" != "false" ]; then current_speed8="95"; else current_speed8="0"; fi
fi

# set memclock frequency (graphics.pl)
if [ "${sudoers,,}" = "true" ] && [ "${memClock_frequency,,}" != "false" ] && [ "${memClock_frequency}" = "300" ]; then echo "$root_pass" | sudo "${PWD}/./graphics.pl" memclock 0; fi
if [ "${sudoers,,}" = "true" ] && [ "${memClock_frequency,,}" != "false" ] && [ "${memClock_frequency}" = "1000" ]; then echo "$root_pass" | sudo "${PWD}/./graphics.pl" memclock 1; fi
if [ "${sudoers,,}" = "true" ] && [ "${memClock_frequency,,}" != "false" ] && [ "${memClock_frequency}" = "2000" ]; then echo "$root_pass" | sudo "${PWD}/./graphics.pl" memclock 2; fi

# set gpuclock frequency (graphics.pl)
if [ "${sudoers,,}" = "true" ] && [ "${gpuClock_frequency,,}" != "false" ] && [ "${gpuClock_frequency}" = "300" ]; then echo "$root_pass" | sudo "${PWD}/./graphics.pl" gpuClock 0; fi
if [ "${sudoers,,}" = "true" ] && [ "${gpuClock_frequency,,}" != "false" ] && [ "${gpuClock_frequency}" = "600" ]; then echo "$root_pass" | sudo "${PWD}/./graphics.pl" gpuClock 1; fi
if [ "${sudoers,,}" = "true" ] && [ "${gpuClock_frequency,,}" != "false" ] && [ "${gpuClock_frequency}" = "900" ]; then echo "$root_pass" | sudo "${PWD}/./graphics.pl" gpuClock 2; fi
if [ "${sudoers,,}" = "true" ] && [ "${gpuClock_frequency,,}" != "false" ] && [ "${gpuClock_frequency}" = "1145" ]; then echo "$root_pass" | sudo "${PWD}/./graphics.pl" gpuClock 3; fi
if [ "${sudoers,,}" = "true" ] && [ "${gpuClock_frequency,,}" != "false" ] && [ "${gpuClock_frequency}" = "1215" ]; then echo "$root_pass" | sudo "${PWD}/./graphics.pl" gpuClock 4; fi
if [ "${sudoers,,}" = "true" ] && [ "${gpuClock_frequency,,}" != "false" ] && [ "${gpuClock_frequency}" = "1257" ]; then echo "$root_pass" | sudo "${PWD}/./graphics.pl" gpuClock 5; fi
if [ "${sudoers,,}" = "true" ] && [ "${gpuClock_frequency,,}" != "false" ] && [ "${gpuClock_frequency}" = "1300" ]; then echo "$root_pass" | sudo "${PWD}/./graphics.pl" gpuClock 6; fi
if [ "${sudoers,,}" = "true" ] && [ "${gpuClock_frequency,,}" != "false" ] && [ "${gpuClock_frequency}" = "1340" ]; then echo "$root_pass" | sudo "${PWD}/./graphics.pl" gpuClock 7; fi

# osd - PageCache, dentries and inodes
if [ -z "$clear_caches" ] || [ "${clear_caches,,}" = "false" ]; then
  cache_output=""
  clear_the_cache=""
elif [ ! -z "$clear_caches" ] && [ "${CPU_name,,}" != "false" ] || [ "${clear_caches,,}" = "true" ]; then
  clear_the_caches=$(echo "echo 3 > /proc/sys/vm/drop_caches") # credit: Riyaj Shamsudeen, blog.pythian.com/performance-tuning-hugepages-in-linux
  cache_output="\n ${Light_Cyan}* ${Light_Blue}Clearing caches${Light_Gray} Daily "
fi

# osd - gpuclock
# TODO: add plural variable for osd
GPUclock=$(sudo -S "${PWD}/./graphics.pl" gpuClock | grep -m 1 "*" | awk '{print $2'})
if [ -z "$gpuClock_frequency" ] || [ "${gpuClock_frequency,,}" != "false" ]; then
  GPUclock_output="\n ${Light_Cyan}* ${Light_Blue}gpuClock set to ${Light_Gray}${GPUclock}"
else
  GPUclock_output="\n ${Light_Cyan}* ${Light_Blue}gpuClock default"
fi

# osd - memclock
# TODO: add plural variable for osd
MEMclock=$("${PWD}/./graphics.pl" memClock | grep -m 1 "*" | awk '{print $2'})
if [ -z "$memClock_frequency" ] || [ "${memClock_frequency,,}" != "false" ]; then
  MEMclock_output="\n ${Light_Cyan}* ${Light_Blue}memClock set to ${Light_Gray}${MEMclock}"
else
  MEMclock_output="\n ${Light_Cyan}* ${Light_Blue}memClock default"
fi

# osd - suspend mode
# TODO: convert suspend seconds into time stamp for osd
if [ -z "$sudoers" ] || [ "${sudoers,,}" != "false" ]; then
  suspend_output=$("\n ${Light_Cyan}* ${Light_Blue}System suspend / Auto wake")
else
  suspend_output=$("\n ${Light_Cyan}* ${Light_Blue}System suspend / Manual wake")
fi

# set the volume on first load
#if [ ! -z "$enable_speech" ] && [ "${enable_speech,,}" = "true" ] && [ ! -z "$volume_limiting" ] && [ "${volume_limiting,,}" = "true" ]; then
#  amixer -D pulse sset Master $am_volume
#  clear
#  echo "setting volume level"
#  echo "volume has been set to daytime for initial load..." | festival --tts
#fi

# osd - user settings (while cooling gpus)
clear
echo -e "${bold}${Light_Cyan} - - - - - - - - - - - - - - -\n Automated Hardware Protection\n - - - - - - - - - - - - - - -${Default}${normal}

 ${Light_Gray}Suspend Computer Settings
 $GPU_user_setting $CPU_user_setting $AIO_user_setting ${Default}
"


# convert number into words - CREDIT: Glenn Jackman - unix.stackexchange.com/a/413475
digits=( "" one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eightteen nineteen )
tens=("" "" twenty thirty forty fifty sixty seventy eighty ninety)
units=("" thousand million billion trillion)
number2words() { local -i number=$((10#$1)); local -i u=0; local words=(); local group; while ((number > 0)); do group=$(hundreds2words $((number % 1000)) ); [[ -n "$group" ]] && group="$group ${units[u]}"; words=("$group" "${words[@]}"); ((u++)); ((number = number / 1000)); done; echo "${words[*]}"; }
hundreds2words() { local -i num=$((10#$1)); if ((num < 20)); then echo "${digits[num]}"; elif ((num < 100)); then echo "${tens[num / 10]} ${digits[num % 10]}"; else echo "${digits[num / 100]} hundred and $("$FUNCNAME" $((num % 100)) )"; fi }

# convert gpuClock to words for better speech
convert_gpuClock_frequency=$(number2words "$gpuClock_frequency")

# convert memClock to words for better speech
convert_memClock_frequency=$(number2words "$memClock_frequency")

# osd - cooling
echo " Cooling GPUs...
"

# vocal - cool down phase
if [ "${sudoers,,}" = "true" ]; then
  if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then
    echo "G. P. U... cooldown phase... activated..." | festival --tts
      # shutdown temps
      # GPU
      if [ ! -z "$shutdown_GPU_temp" ] && [ "${shutdown_GPU_temp,,}" != "false" ]; then echo "G. P. U... shut down temperature is set to $shutdown_GPU_temp degrees..." | festival --tts; fi
      # CPU
      if [ ! -z "$shutdown_CPU_temp" ] && [ "${shutdown_CPU_temp,,}" != "false" ]; then echo "C. P. U... shut down temperature is set to $shutdown_CPU_temp degrees..." | festival --tts; fi
      # AIO
      if [ ! -z "$shutdown_AIO_temp" ] && [ "${shutdown_AIO_temp,,}" != "false" ]; then echo "A. I. O... shut down temperature is set to $shutdown_AIO_temp degrees..." | festival --tts; fi    

    # gpuClock setting
    # TODO: set plural incase only one GPU is being utilized
    if [ ! -z "$gpuClock_frequency" ] && [ "${gpuClock_frequency,,}" != "false" ]; then echo "G. P. U... frequencies are set to $convert_gpuClock_frequency megahertz..." | festival --tts; fi
    # memClock setting
    if [ ! -z "$memClock_frequency" ] && [ "${memClock_frequency,,}" != "false" ]; then echo "G. P. U... memory clocks are set to $convert_memClock_frequency megahertz..." | festival --tts; fi 
    # clear caches is enabled
    if [ ! -z "$clear_caches" ] && [ "${clear_caches,,}" = "true" ]; then echo "deleting system caches is enabled..." | festival --tts; fi

    # happy mining
    echo "I am now automating your system..." | festival --tts
    echo "go... and play... i got this..." | festival --tts
  fi
fi

# osd - countdown the GPU cooling time
first_run_cool_down=$((1 * 30))
while [ $first_run_cool_down -gt 0 ]; do
   echo -ne "${Light_Gray} Please wait ${first_run_cool_down}s\033[0K\r"
   sleep 1
   : $((first_run_cool_down--))
done

# speech - system update
update_already_spoken="false"

# speech - let vocal update know we have not shut down yet
was_shutdown="false"

# volume limiting - let volume limiting know we are optimized for daytime
noise_state="Day"

# caches - let PageCache, dentries and inodes know we are not cleared yet
monday_cache="false"; tuesday_cache="false"; wednesday_cache="false"; thursday_cache="false"; friday_cache="false"; saturday_cache="false"; sunday_cache="false"

# vocal - user suspend time is 1 Hr
if [ "$suspend_time" = "3600" ]; then
  user_suspend_time="... system wake is set for 1 hour..."
fi

# vocal - user suspend time is 2 Hrs
if [ "$suspend_time" = "7200" ]; then
  user_suspend_time="... system wake is set for 2 hours..."
fi

# vocal - user suspend time is 3 Hrs
if [ "$suspend_time" = "10800" ]; then
  user_suspend_time="... system wake is set for 3 hours..."
fi

# vocal - user suspend time is 4 Hrs
if [ "$suspend_time" = "14400" ]; then
  user_suspend_time="... system wake is set for 4 hours..."
fi

# vocal - user suspend time is not using a default value
if [ "$suspend_time" != "3600" ] || [ "$suspend_time" != "7200" ] || [ "$suspend_time" != "10800" ] || [ "$suspend_time" != "14400" ]; then
  user_suspend_time="..."
fi



######
######	LOOP
######	- infinite loop
######

while true; do



  ######
  ######	DATE AND TIME
  ######	- time/date related stuff
  ######

  # TODO: fix the echoes inside the variables
  DATE="`date`"
  DAY=$(echo "$DATE" | awk '{print $1}')
  minute=$(echo "$DATE" | awk '{print $4}' | sed 's/[^0-9]*//g' | cut -c 3-4)
  HOUR=$(echo "$DATE" | awk '{print $4}' | sed 's/[^0-9]*//g' | cut -c 1-2); hour=$(echo $HOUR)



  ######
  ######	Volume Limiting
  ######	- limit noise for after hours
  ######

  # set am volume
  day_volume_speech="volume is now optimized for daytime..."
  night_volume_speech="volume is now optimized for night time..."

  # am volume is set to 9am - 8pm
  if [ ! -z "$enable_speech" ] && [ "${enable_speech,,}" = "true" ] && [ ! -z "$volume_limiting" ] && [ "${volume_limiting,,}" = "true" ] && [ "$noise_state" != "Day" ]; then
    if [ "$hour" = "09" ] || [ "$hour" = "10" ] || [ "$hour" = "11" ] || [ "$hour" = "12" ] || [ "$hour" = "13" ] || [ "$hour" = "14" ] || [ "$hour" = "15" ] || [ "$hour" = "16" ] || [ "$hour" = "17" ] || [ "$hour" = "18" ] || [ "$hour" = "19" ]; then amixer -D pulse sset Master ${am_volume}; clear; echo "$day_volume_speech"; echo "$day_volume_speech" | festival --tts; noise_state="Day"; clear; fi
  fi

  # pm volume is set to 8pm - 9am
  if [ ! -z "$enable_speech" ] && [ "${enable_speech,,}" = "true" ] && [ ! -z "$volume_limiting" ] && [ "${volume_limiting,,}" = "true" ] && [ "$noise_state" != "Night" ]; then
    if [ "$hour" = "20" ] || [ "$hour" = "21" ] || [ "$hour" = "22" ] || [ "$hour" = "23" ] || [ "$hour" = "24" ] || [ "$hour" = "01" ] || [ "$hour" = "02" ] || [ "$hour" = "03" ] || [ "$hour" = "04" ] || [ "$hour" = "05" ] || [ "$hour" = "06" ] || [ "$hour" = "07" ] || [ "$hour" = "08" ]; then amixer -D pulse sset Master ${pm_volume}; clear; echo "$day_volume_speech"; echo "$night_volume_speech" | festival --tts; noise_state="Night"; clear; fi
  fi



  ######
  ######	CHECK NETWORK
  ######	- check default gateway
  ######

  connection_failed=""
  ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && connection_test="pass" || connection_test="fail"
  if [ $connection_test = "fail" ]; then
    connection_failed="\n${Red}WARNING! ${Default}NO CONNECTION DETECTED"
    if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "WARNING... WARNING... WARNING... CONNECTION IS DOWN... WARNING... WARNING... WARNING... CONNECTION IS DOWN..." | festival --tts; fi
    # OSD - no connection
    clear
    echo "${Red}WARNING! ${Default}NO CONNECTION DETECTED"
    sleep 30
    clear
  fi



  ######
  ######	SUSPEND
  ######	- read sensor temps and suspend if hardware gets too hot
  ######

  # time to blast GPU fans at max after system wake
  wakeup_cool_time="30"

  # wake up speech
  wake_up_speech_leading="I just woke up..."
  wake_up_speech_trailing="cool down phase... activated..."

  # GPU 01
  if [ "${GPU_name_01,,}" != "false" ]; then
    # stats
    GPU_temp_01=$(sensors | sed -e "1,/${GPU_name_01}/d" | grep -m 1 temp | awk '{print $2}' | sed 's/[^0-9]*//g' | cut -c 1-2)
    GPU_fan_speed_01=$(sensors | sed -e "1,/${GPU_name_01}/d" | grep -m 1 fan | awk '{print $2}')
    # suspend and set cool down time after wake so we don't read a false negative temp and prematurely shut down again
    if [ "$GPU_temp_01" -ge "$shutdown_GPU_temp" ]; then
      if [ "${sudoers,,}" = "true" ]; then
        if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "WARNING... P. U... 1 has triggered a system shutdown... temperature is too high${user_suspend_time}" | festival --tts; fi
        sudo -S rtcwake -m disk -s $suspend_time; sleep $wakeup_cool_time; was_shutdown="true"
      else
        systemctl suspend
      fi
    fi
    # osd
      if [ $GPU_temp_01 -ge $((shutdown_GPU_temp-3)) ]; then
        GPU1_color=${Red}
      else
        GPU1_color=${Light_Green}
      fi
    GPU_output_01="\n ${Light_Cyan}* ${Light_Green}GPU Temp ${GPU1_color}${GPU_temp_01}.0°C ${Light_Gray}Fan $GPU_fan_speed_01 Rpm${Light_Gray}"
  else
    GPU_output_01=""
    GPU_temp_01="0"
  fi

  # GPU 02
  if [ "${GPU_name_02,,}" != "false" ]; then
    # stats
    GPU_temp_02=$(sensors | sed -e "1,/${GPU_name_02}/d" | grep -m 1 temp | awk '{print $2}' | sed 's/[^0-9]*//g' | cut -c 1-2)
    GPU_fan_speed_02=$(sensors | sed -e "1,/${GPU_name_02}/d" | grep -m 1 fan | awk '{print $2}')
    # suspend and set cool down time after wake so we don't read a false negative temp and prematurely shut down again
    if [ "$GPU_temp_02" -ge "$shutdown_GPU_temp" ]; then
      if [ "${sudoers,,}" = "true" ]; then
        if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "WARNING... G. P. U... 2 has triggered a system shutdown... temperature is too high${user_suspend_time}" | festival --tts; fi
        sudo -S rtcwake -m disk -s $suspend_time; sleep $wakeup_cool_time; was_shutdown="true"
      else
        systemctl suspend
      fi
    fi
    # osd
      if [ $GPU_temp_02 -ge $((shutdown_GPU_temp-3)) ]; then
        GPU2_color=${Red}
      else
        GPU2_color=${Light_Green}
      fi
    GPU_output_02="\n ${Light_Cyan}* ${Light_Green}GPU Temp ${GPU2_color}${GPU_temp_02}.0°C ${Light_Gray}Fan $GPU_fan_speed_02 Rpm${Light_Gray}"
  else
    GPU_output_02=""
    GPU_temp_02="0"
  fi

  # GPU 03
  if [ "${GPU_name_03,,}" != "false" ]; then
    # stats
    GPU_temp_03=$(sensors | sed -e "1,/${GPU_name_03}/d" | grep -m 1 temp | awk '{print $2}' | sed 's/[^0-9]*//g' | cut -c 1-2)
    GPU_fan_speed_03=$(sensors | sed -e "1,/${GPU_name_03}/d" | grep -m 1 fan | awk '{print $2}')
    # suspend and set cool down time after wake so we don't read a false negative temp and prematurely shut down again
    if [ "$GPU_temp_03" -ge "$shutdown_GPU_temp" ]; then
      if [ "${sudoers,,}" = "true" ]; then
        if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "WARNING... G. P. U... 3 has triggered a system shutdown... temperature is too high${user_suspend_time}" | festival --tts; fi
        sudo -S rtcwake -m disk -s $suspend_time; sleep $wakeup_cool_time; was_shutdown="true"
      else
        systemctl suspend
      fi
    fi
    # osd
      if [ $GPU_temp_03 -ge $((shutdown_GPU_temp-3)) ]; then
        GPU3_color=${Red}
      else
        GPU3_color=${Light_Green}
      fi
    GPU_output_03="\n ${Light_Cyan}* ${Light_Green}GPU Temp ${GPU3_color}${GPU_temp_03}.0°C ${Light_Gray}Fan $GPU_fan_speed_03 Rpm${Light_Gray}"
  else
    GPU_output_03=""
    GPU_temp_03="0"
  fi

  # GPU 04
  if [ "${GPU_name_04,,}" != "false" ]; then
    # stats
    GPU_temp_04=$(sensors | sed -e "1,/${GPU_name_04}/d" | grep -m 1 temp | awk '{print $2}' | sed 's/[^0-9]*//g' | cut -c 1-2)
    GPU_fan_speed_04=$(sensors | sed -e "1,/${GPU_name_04}/d" | grep -m 1 fan | awk '{print $2}')
    # suspend and set cool down time after wake so we don't read a false negative temp and prematurely shut down again
    if [ "$GPU_temp_04" -ge "$shutdown_GPU_temp" ]; then
      if [ "${sudoers,,}" = "true" ]; then
        if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "WARNING... G. P. U... 4 has triggered a system shutdown... temperature is too high${user_suspend_time}" | festival --tts; fi
        sudo -S rtcwake -m disk -s $suspend_time; sleep $wakeup_cool_time; was_shutdown="true"
      else
        systemctl suspend
      fi
    fi
    # osd
      if [ $GPU_temp_04 -ge $((shutdown_GPU_temp-3)) ]; then
        GPU4_color=${Red}
      else
        GPU4_color=${Light_Green}
      fi
    GPU_output_04="\n ${Light_Cyan}* ${Light_Green}GPU Temp ${GPU4_color}${GPU_temp_04}.0°C ${Light_Gray}Fan $GPU_fan_speed_04 Rpm${Light_Gray}"
  else
    GPU_output_04=""
    GPU_temp_04="0"
  fi

  # GPU 05
  if [ "${GPU_name_05,,}" != "false" ]; then
    # stats
    GPU_temp_05=$(sensors | sed -e "1,/${GPU_name_05}/d" | grep -m 1 temp | awk '{print $2}' | sed 's/[^0-9]*//g' | cut -c 1-2)
    GPU_fan_speed_05=$(sensors | sed -e "1,/${GPU_name_05}/d" | grep -m 1 fan | awk '{print $2}')
    # suspend and set cool down time after wake so we don't read a false negative temp and prematurely shut down again
    if [ "$GPU_temp_05" -ge "$shutdown_GPU_temp" ]; then
      if [ "${sudoers,,}" = "true" ]; then
        if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "WARNING... G. P. U... 5 has triggered a system shutdown... temperature is too high${user_suspend_time}" | festival --tts; fi
        sudo -S rtcwake -m disk -s $suspend_time; sleep $wakeup_cool_time; was_shutdown="true"
      else
        systemctl suspend
      fi
    fi
    # osd
      if [ $GPU_temp_05 -ge $((shutdown_GPU_temp-3)) ]; then
        GPU5_color=${Red}
      else
        GPU5_color=${Light_Green}
      fi
    GPU_output_05="\n ${Light_Cyan}* ${Light_Green}GPU Temp ${GPU5_color}${GPU_temp_05}.0°C ${Light_Gray}Fan $GPU_fan_speed_05 Rpm${Light_Gray}"
  else
    GPU_output_05=""
    GPU_temp_05="0"
  fi

  # GPU 06
  if [ "${GPU_name_06,,}" != "false" ]; then
    # stats
    GPU_temp_06=$(sensors | sed -e "1,/${GPU_name_06}/d" | grep -m 1 temp | awk '{print $2}' | sed 's/[^0-9]*//g' | cut -c 1-2)
    GPU_fan_speed_06=$(sensors | sed -e "1,/${GPU_name_06}/d" | grep -m 1 fan | awk '{print $2}')
    # suspend and set cool down time after wake so we don't read a false negative temp and prematurely shut down again
    if [ "$GPU_temp_06" -ge "$shutdown_GPU_temp" ]; then
      if [ "${sudoers,,}" = "true" ]; then
        if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "WARNING... G. P. U... 6 has triggered a system shutdown... temperature is too high${user_suspend_time}" | festival --tts; fi
        sudo -S rtcwake -m disk -s $suspend_time; sleep $wakeup_cool_time; was_shutdown="true"
      else
        systemctl suspend
      fi
    fi
    # osd
      if [ $GPU_temp_06 -ge $((shutdown_GPU_temp-3)) ]; then
        GPU6_color=${Red}
      else
        GPU6_color=${Light_Green}
      fi
    GPU_output_06="\n ${Light_Cyan}* ${Light_Green}GPU Temp ${GPU6_color}${GPU_temp_06}.0°C ${Light_Gray}Fan $GPU_fan_speed_06 Rpm${Light_Gray}"
  else
    GPU_output_06=""
    GPU_temp_06="0"
  fi

  # GPU 07
  if [ "${GPU_name_07,,}" != "false" ]; then
    # stats
    GPU_temp_07=$(sensors | sed -e "1,/${GPU_name_07}/d" | grep -m 1 temp | awk '{print $2}' | sed 's/[^0-9]*//g' | cut -c 1-2)
    GPU_fan_speed_07=$(sensors | sed -e "1,/${GPU_name_07}/d" | grep -m 1 fan | awk '{print $2}')
    # suspend and set cool down time after wake so we don't read a false negative temp and prematurely shut down again
    if [ "$GPU_temp_07" -ge "$shutdown_GPU_temp" ]; then
      if [ "${sudoers,,}" = "true" ]; then
        if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "WARNING... G. P. U... 7 has triggered a system shutdown... temperature is too high${user_suspend_time}" | festival --tts; fi
        sudo -S rtcwake -m disk -s $suspend_time; sleep $wakeup_cool_time; was_shutdown="true"
      else
        systemctl suspend
      fi
    fi
    # osd
      if [ $GPU_temp_07 -ge $((shutdown_GPU_temp-3)) ]; then
        GPU7_color=${Red}
      else
        GPU7_color=${Light_Green}
      fi
    GPU_output_07="\n ${Light_Cyan}* ${Light_Green}GPU Temp ${GPU7_color}${GPU_temp_07}.0°C ${Light_Gray}Fan $GPU_fan_speed_07 Rpm${Light_Gray}"
  else
    GPU_output_07=""
    GPU_temp_07="0"
  fi

  # GPU 08
  if [ "${GPU_name_08,,}" != "false" ]; then
    # stats
    GPU_temp_08=$(sensors | sed -e "1,/${GPU_name_08}/d" | grep -m 1 temp | awk '{print $2}' | sed 's/[^0-9]*//g' | cut -c 1-2)
    GPU_fan_speed_08=$(sensors | sed -e "1,/${GPU_name_08}/d" | grep -m 1 fan | awk '{print $2}')
    # suspend and set cool down time after wake so we don't read a false negative temp and prematurely shut down again
    if [ "$GPU_temp_08" -ge "$shutdown_GPU_temp" ]; then
      if [ "${sudoers,,}" = "true" ]; then
        if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "WARNING... G. P. U... 8 has triggered a system shutdown... temperature is too high${user_suspend_time}" | festival --tts; fi
        sudo -S rtcwake -m disk -s $suspend_time; sleep $wakeup_cool_time; was_shutdown="true"
      else
        systemctl suspend
      fi
    fi
    # osd
      if [ $GPU_temp_08 -ge $((shutdown_GPU_temp-3)) ]; then
        GPU8_color=${Red}
      else
        GPU8_color=${Light_Green}
      fi
    GPU_output_08="\n ${Light_Cyan}* ${Light_Green}GPU Temp ${GPU8_color}${GPU_temp_08}.0°C ${Light_Gray}Fan $GPU_fan_speed_08 Rpm${Light_Gray}"
  else
    GPU_output_08=""
    GPU_temp_08="0"
  fi

  # CPU
  if [ "${CPU_name,,}" != "false" ]; then
    # stats
    CPU_temp=$(sensors | sed -e "1,/${CPU_name}/d" | grep -m 1 temp | awk '{print $2}' | sed 's/[^0-9]*//g' | cut -c 1-2)
    CPU_temp_point=$(sensors | sed -e "1,/${CPU_name}/d" | grep -m 1 temp | awk '{print $2}' | sed 's/[^0-9]*//g' | cut -c 1-1)
    CPU_high_temp=$(sensors | sed -e "1,/${CPU_name}/d" | grep -m 1 temp | awk '{print $3, $4, $5}')
    # suspend and set cool down time after wake so we don't read a false negative temp and prematurely shut down again
    if [ "$CPU_temp" -ge "$shutdown_CPU_temp" ]; then
      if [ "${sudoers,,}" = "true" ]; then
        if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "WARNING... C. P. U... has triggered a system shutdown... temperature is too high${user_suspend_time}" | festival --tts; fi
        sudo -S rtcwake -m disk -s $suspend_time; sleep $wakeup_cool_time; was_shutdown="true"
      else
        systemctl suspend
      fi
    fi
    # osd
      if [ $CPU_temp -ge $((shutdown_CPU_temp-3)) ]; then
        CPU_color=${Red}
      else
        CPU_color=${Light_Yellow}
      fi
    CPU_output="\n ${Light_Cyan}* ${Light_Yellow}CPU Temp ${CPU_color}${CPU_temp}.${CPU_temp_point}°C${Light_Gray} $CPU_high_temp"
  else
    CPU_output=""
  fi

  # AIO
  if [ "${AIO_name,,}" != "false" ] && [ "${CPU_name,,}" != "false" ]; then
    # stats
    AIO_temp=$(sensors | sed -e "1,/${AIO_name}/d" | grep -m 1 temp | awk '{print $2}' | sed 's/[^0-9]*//g' | cut -c 1-2)
    AIO_temp_point=$(sensors | sed -e "1,/${AIO_name}/d" | grep -m 1 temp | awk '{print $2}' | sed 's/[^0-9]*//g' | cut -c 1-1)
    AIO_high_temp=$(sensors | sed -e "1,/${AIO_name}/d" | grep -m 1 temp | awk '{print $3, $4, $5}')
    # suspend and set cool down time after wake so we don't read a false negative temp and prematurely shut down again
    if [ "$AIO_temp" -ge "$shutdown_GPU_temp" ]; then
      if [ "${sudoers,,}" = "true" ]; then
        if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "WARNING... A. I. O... has triggered a system shutdown... temperature is too high${user_suspend_time}" | festival --tts; fi
        sudo -S rtcwake -m disk -s $suspend_time; sleep $wakeup_cool_time; was_shutdown="true"
      else
        systemctl suspend
      fi
    fi
    # osd
      if [ $AIO_temp -ge $((shutdown_AIO_temp-3)) ]; then
        AIO_color=${Red}
      else
        AIO_color=${Light_Magenta}
      fi
    AIO_output="\n ${Light_Cyan}* ${Light_Magenta}AIO Temp ${AIO_color}${AIO_temp}.${AIO_temp_point}°C${Light_Gray} $AIO_high_temp"
  else
    AIO_output=""
  fi

  # - graphics.pl (needs to be loaded twice to grab any updated settings)
  echo $GPUclock; echo $GPUclock
  echo $MEMclock; echo $MEMclock

  # osd clear
  clear



  ######
  ######	GPU FAN CONTROL AUTOMATION
  ######	- adjust the gpu fan speeds (with "shutdown_GPU_temp" being the high temp setting)
  ######

  # ! WARNING: 50% is lowest fan speed before GPU warning | 95% is highest fan speed before GPU warning

  # GPU 01
  speech1="G. P. U... 1 fan is now... "
  if [ ! -z "$GPU_name_01" ] && [ "${GPU_name_01,,}" != "false" ] && [ $GPU_temp_01 -lt $((shutdown_GPU_temp-45)) ]; then
    if [ $current_speed1 -ne "50" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 0 -s 50
      current_speed1="50"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech1}${current_speed1}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_01" ] && [ "${GPU_name_01,,}" != "false" ] && [ $GPU_temp_01 -ge $((shutdown_GPU_temp-40)) ] && [ $GPU_temp_01 -lt $((shutdown_GPU_temp-35)) ]; then 
    if [ $current_speed1 -ne "60" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 0 -s 60
      current_speed1="60"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech1}${current_speed1}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_01" ] && [ "${GPU_name_01,,}" != "false" ] && [ $GPU_temp_01 -ge $((shutdown_GPU_temp-35)) ] && [ $GPU_temp_01 -lt $((shutdown_GPU_temp-30)) ]; then 
    if [ $current_speed1 -ne "65" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 0 -s 65
      current_speed1="65"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech1}${current_speed1}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_01" ] && [ "${GPU_name_01,,}" != "false" ] && [ $GPU_temp_01 -ge $((shutdown_GPU_temp-30)) ] && [ $GPU_temp_01 -lt $((shutdown_GPU_temp-25)) ]; then 
    if [ $current_speed1 -ne "70" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 0 -s 70
      current_speed1="70"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech1}${current_speed1}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_01" ] && [ "${GPU_name_01,,}" != "false" ] && [ $GPU_temp_01 -ge $((shutdown_GPU_temp-25)) ] && [ $GPU_temp_01 -lt $((shutdown_GPU_temp-20)) ]; then 
    if [ $current_speed1 -ne "75" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 0 -s 75
      current_speed1="75"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech1}${current_speed1}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_01" ] && [ "${GPU_name_01,,}" != "false" ] && [ $GPU_temp_01 -ge $((shutdown_GPU_temp-20)) ] && [ $GPU_temp_01 -lt $((shutdown_GPU_temp-15)) ]; then
    if [ $current_speed1 -ne "80" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 0 -s 80
      current_speed1="80"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech1}${current_speed1}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_01" ] && [ "${GPU_name_01,,}" != "false" ] && [ $GPU_temp_01 -ge $((shutdown_GPU_temp-15)) ] && [ $GPU_temp_01 -lt $((shutdown_GPU_temp-10)) ]; then 
    if [ $current_speed1 -ne "85" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 0 -s 85
      current_speed1="85"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech1}${current_speed1}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_01" ] && [ "${GPU_name_01,,}" != "false" ] && [ $GPU_temp_01 -ge $((shutdown_GPU_temp-10)) ] && [ $GPU_temp_01 -lt $((shutdown_GPU_temp-5)) ]; then 
    if [ $current_speed1 -ne "90" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 0 -s 90
      current_speed1="90"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech1}${current_speed1}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_01" ] && [ "${GPU_name_01,,}" != "false" ] && [ $GPU_temp_01 -ge $((shutdown_GPU_temp-5)) ]; then
    if [ $current_speed1 -ne "95" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 0 -s 95
      current_speed1="95"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech1}${current_speed1}%..." | festival --tts; fi
    fi
  fi

  # GPU 02
  speech2="G. P. U... 2 fan is now... "
  if [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ] && [ $GPU_temp_02 -le $((shutdown_GPU_temp-45)) ]; then
    if [ $current_speed2 -ne "50" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 1 -s 50
      current_speed2="50"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech2}${current_speed2}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ] && [ $GPU_temp_02 -ge $((shutdown_GPU_temp-40)) ] && [ $GPU_temp_02 -lt $((shutdown_GPU_temp-35)) ]; then 
    if [ $current_speed2 -ne "60" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 1 -s 60
      current_speed2="60"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech2}${current_speed2}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ] && [ $GPU_temp_02 -ge $((shutdown_GPU_temp-35)) ] && [ $GPU_temp_02 -lt $((shutdown_GPU_temp-30)) ]; then 
    if [ $current_speed2 -ne "65" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 1 -s 65
      current_speed2="65"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech2}${current_speed2}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ] && [ $GPU_temp_02 -ge $((shutdown_GPU_temp-30)) ] && [ $GPU_temp_02 -lt $((shutdown_GPU_temp-25)) ]; then 
    if [ $current_speed2 -ne "70" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 1 -s 70
      current_speed2="70"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech2}${current_speed2}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ] && [ $GPU_temp_02 -ge $((shutdown_GPU_temp-25)) ] && [ $GPU_temp_02 -lt $((shutdown_GPU_temp-20)) ]; then 
    if [ $current_speed2 -ne "75" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 1 -s 75
      current_speed2="75"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech2}${current_speed2}%..." | festival --tts; fi
    fi
 fi

  if [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ] && [ $GPU_temp_02 -ge $((shutdown_GPU_temp-20)) ] && [ $GPU_temp_02 -lt $((shutdown_GPU_temp-15)) ]; then 
    if [ $current_speed2 -ne "80" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 1 -s 80
      current_speed2="80"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech2}${current_speed2}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ] && [ $GPU_temp_02 -ge $((shutdown_GPU_temp-15)) ] && [ $GPU_temp_02 -lt $((shutdown_GPU_temp-10)) ]; then 
    if [ $current_speed2 -ne "85" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 1 -s 85
      current_speed2="85"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech2}${current_speed2}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ] && [ $GPU_temp_02 -ge $((shutdown_GPU_temp-10)) ] && [ $GPU_temp_02 -lt $((shutdown_GPU_temp-5)) ]; then 
    if [ $current_speed2 -ne "90" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 1 -s 90
      current_speed2="90"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech2}${current_speed2}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ] && [ $GPU_temp_02 -ge $((shutdown_GPU_temp-5)) ]; then
    if [ $current_speed2 -ne "95" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 1 -s 95
      current_speed2="95"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech2}${current_speed2}%..." | festival --tts; fi
    fi
  fi

  # GPU 03
  speech3="G. P. U... 3 fan is now... "
  if [ ! -z "$GPU_name_03" ] && [ "${GPU_name_03,,}" != "false" ] && [ $GPU_temp_03 -le $((shutdown_GPU_temp-45)) ]; then
    if [ $current_speed3 -ne "50" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 2 -s 50
      current_speed3="50"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech3}${current_speed3}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_03" ] && [ "${GPU_name_03,,}" != "false" ] && [ $GPU_temp_03 -ge $((shutdown_GPU_temp-40)) ] && [ $GPU_temp_03 -lt $((shutdown_GPU_temp-35)) ]; then 
    if [ $current_speed3 -ne "60" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 2 -s 60
      current_speed3="60"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech3}${current_speed3}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_03" ] && [ "${GPU_name_03,,}" != "false" ] && [ $GPU_temp_03 -ge $((shutdown_GPU_temp-35)) ] && [ $GPU_temp_03 -lt $((shutdown_GPU_temp-30)) ]; then 
    if [ $current_speed3 -ne "65" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 2 -s 65
      current_speed3="65"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech3}${current_speed3}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_03" ] && [ "${GPU_name_03,,}" != "false" ] && [ $GPU_temp_03 -ge $((shutdown_GPU_temp-30)) ] && [ $GPU_temp_03 -lt $((shutdown_GPU_temp-25)) ]; then 
    if [ $current_speed3 -ne "70" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 2 -s 70
      current_speed3="70"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech3}${current_speed3}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_03" ] && [ "${GPU_name_03,,}" != "false" ] && [ $GPU_temp_03 -ge $((shutdown_GPU_temp-25)) ] && [ $GPU_temp_03 -lt $((shutdown_GPU_temp-20)) ]; then 
    if [ $current_speed3 -ne "75" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 2 -s 75
      current_speed3="75"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech3}${current_speed3}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_03" ] && [ "${GPU_name_03,,}" != "false" ] && [ $GPU_temp_03 -ge $((shutdown_GPU_temp-20)) ] && [ $GPU_temp_03 -lt $((shutdown_GPU_temp-15)) ]; then 
    if [ $current_speed3 -ne "80" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 2 -s 80
      current_speed3="80"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech3}${current_speed3}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_03" ] && [ "${GPU_name_03,,}" != "false" ] && [ $GPU_temp_03 -ge $((shutdown_GPU_temp-15)) ] && [ $GPU_temp_03 -lt $((shutdown_GPU_temp-10)) ]; then 
    if [ $current_speed3 -ne "85" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 2 -s 85
      current_speed3="85"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech3}${current_speed3}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_03" ] && [ "${GPU_name_03,,}" != "false" ] && [ $GPU_temp_03 -ge $((shutdown_GPU_temp-10)) ] && [ $GPU_temp_03 -lt $((shutdown_GPU_temp-5)) ]; then 
    if [ $current_speed3 -ne "90" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 2 -s 90
      current_speed3="90"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech3}${current_speed3}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_03" ] && [ "${GPU_name_03,,}" != "false" ] && [ $GPU_temp_03 -ge $((shutdown_GPU_temp-5)) ]; then 
    if [ $current_speed3 -ne "95" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 2 -s 95
      current_speed3="95"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech3}${current_speed3}%..." | festival --tts; fi
    fi
  fi

  # GPU 04
  speech4="G. P. U... 4 fan is now... "
  if [ ! -z "$GPU_name_04" ] && [ "${GPU_name_04,,}" != "false" ] && [ $GPU_temp_04 -le $((shutdown_GPU_temp-45)) ]; then
    if [ $current_speed4 -ne "50" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 3 -s 50
      current_speed4="50"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech4}${current_speed4}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_04" ] && [ "${GPU_name_04,,}" != "false" ] && [ $GPU_temp_04 -ge $((shutdown_GPU_temp-40)) ] && [ $GPU_temp_04 -lt $((shutdown_GPU_temp-35)) ]; then 
    if [ $current_speed4 -ne "60" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 3 -s 60
      current_speed4="60"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech4}${current_speed4}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_04" ] && [ "${GPU_name_04,,}" != "false" ] && [ $GPU_temp_04 -ge $((shutdown_GPU_temp-35)) ] && [ $GPU_temp_04 -lt $((shutdown_GPU_temp-30)) ]; then 
    if [ $current_speed4 -ne "65" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 3 -s 65
      current_speed4="65"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech4}${current_speed4}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_04" ] && [ "${GPU_name_04,,}" != "false" ] && [ $GPU_temp_04 -ge $((shutdown_GPU_temp-30)) ] && [ $GPU_temp_04 -lt $((shutdown_GPU_temp-25)) ]; then 
    if [ $current_speed4 -ne "70" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 3 -s 70
      current_speed4="70"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech4}${current_speed4}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_04" ] && [ "${GPU_name_04,,}" != "false" ] && [ $GPU_temp_04 -ge $((shutdown_GPU_temp-25)) ] && [ $GPU_temp_04 -lt $((shutdown_GPU_temp-20)) ]; then 
    if [ $current_speed4 -ne "75" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 3 -s 75
      current_speed4="75"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech4}${current_speed4}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_04" ] && [ "${GPU_name_04,,}" != "false" ] && [ $GPU_temp_04 -ge $((shutdown_GPU_temp-20)) ] && [ $GPU_temp_04 -lt $((shutdown_GPU_temp-15)) ]; then 
    if [ $current_speed4 -ne "80" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 3 -s 80
      current_speed4="80"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech4}${current_speed4}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_04" ] && [ "${GPU_name_04,,}" != "false" ] && [ $GPU_temp_04 -ge $((shutdown_GPU_temp-15)) ] && [ $GPU_temp_04 -lt $((shutdown_GPU_temp-10)) ]; then 
    if [ $current_speed4 -ne "85" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 3 -s 85
      current_speed4="85"
if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech4}${current_speed4}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_04" ] && [ "${GPU_name_04,,}" != "false" ] && [ $GPU_temp_04 -ge $((shutdown_GPU_temp-10)) ] && [ $GPU_temp_04 -lt $((shutdown_GPU_temp-5)) ]; then 
    if [ $current_speed4 -ne "90" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 3 -s 90
      current_speed4="90"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech4}${current_speed4}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_04" ] && [ "${GPU_name_04,,}" != "false" ] && [ $GPU_temp_04 -ge $((shutdown_GPU_temp-5)) ]; then
    if [ $current_speed4 -ne "95" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 3 -s 95
      current_speed4="95"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech4}${current_speed4}%..." | festival --tts; fi
    fi
  fi


  # GPU 05
  speech5="G. P. U... 5 fan is now... "
  if [ ! -z "$GPU_name_05" ] && [ "${GPU_name_05,,}" != "false" ] && [ $GPU_temp_05 -le $((shutdown_GPU_temp-45)) ]; then
    if [ $current_speed5 -ne "50" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 4 -s 50
      current_speed5="50"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech5}${current_speed5}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_05" ] && [ "${GPU_name_05,,}" != "false" ] && [ $GPU_temp_05 -ge $((shutdown_GPU_temp-40)) ] && [ $GPU_temp_05 -lt $((shutdown_GPU_temp-35)) ]; then 
    if [ $current_speed5 -ne "60" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 4 -s 60
      current_speed5="60"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech5}${current_speed5}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_05" ] && [ "${GPU_name_05,,}" != "false" ] && [ $GPU_temp_05 -ge $((shutdown_GPU_temp-35)) ] && [ $GPU_temp_05 -lt $((shutdown_GPU_temp-30)) ]; then 
    if [ $current_speed5 -ne "65" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 4 -s 65
      current_speed5="65"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech5}${current_speed5}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_05" ] && [ "${GPU_name_05,,}" != "false" ] && [ $GPU_temp_05 -ge $((shutdown_GPU_temp-30)) ] && [ $GPU_temp_05 -lt $((shutdown_GPU_temp-25)) ]; then 
    if [ $current_speed5 -ne "70" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 4 -s 70
      current_speed5="70"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech5}${current_speed5}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_05" ] && [ "${GPU_name_05,,}" != "false" ] && [ $GPU_temp_05 -ge $((shutdown_GPU_temp-25)) ] && [ $GPU_temp_05 -lt $((shutdown_GPU_temp-20)) ]; then 
    if [ $current_speed5 -ne "75" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 4 -s 75
      current_speed5="75"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech5}${current_speed5}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_05" ] && [ "${GPU_name_05,,}" != "false" ] && [ $GPU_temp_05 -ge $((shutdown_GPU_temp-20)) ] && [ $GPU_temp_05 -lt $((shutdown_GPU_temp-15)) ]; then 
    if [ $current_speed5 -ne "80" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 4 -s 80
      current_speed5="80"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech5}${current_speed5}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_05" ] && [ "${GPU_name_05,,}" != "false" ] && [ $GPU_temp_05 -ge $((shutdown_GPU_temp-15)) ] && [ $GPU_temp_05 -lt $((shutdown_GPU_temp-10)) ]; then 
    if [ $current_speed5 -ne "85" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 4 -s 85
      current_speed5="85"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech5}${current_speed5}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_05" ] && [ "${GPU_name_05,,}" != "false" ] && [ $GPU_temp_05 -ge $((shutdown_GPU_temp-10)) ] && [ $GPU_temp_05 -lt $((shutdown_GPU_temp-5)) ]; then 
    if [ $current_speed5 -ne "90" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 4 -s 90
      current_speed5="90"
if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech5}${current_speed5}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_05" ] && [ "${GPU_name_05,,}" != "false" ] && [ $GPU_temp_05 -ge $((shutdown_GPU_temp-5)) ]; then
    if [ $current_speed5 -ne "95" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 4 -s 95
      current_speed5="95"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech5}${current_speed5}%..." | festival --tts; fi
    fi
  fi


  # GPU 06
  speech6="G. P. U... 6 fan is now... "
  if [ ! -z "$GPU_name_06" ] && [ "${GPU_name_06,,}" != "false" ] && [ $GPU_temp_06 -le $((shutdown_GPU_temp-45)) ]; then
    if [ $current_speed6 -ne "50" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 5 -s 50
      current_speed6="50"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech6}${current_speed6}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_06" ] && [ "${GPU_name_06,,}" != "false" ] && [ $GPU_temp_06 -ge $((shutdown_GPU_temp-40)) ] && [ $GPU_temp_06 -lt $((shutdown_GPU_temp-35)) ]; then 
    if [ $current_speed6 -ne "60" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 5 -s 60
      current_speed6="60"
if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech6}${current_speed6}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_06" ] && [ "${GPU_name_06,,}" != "false" ] && [ $GPU_temp_06 -ge $((shutdown_GPU_temp-35)) ] && [ $GPU_temp_06 -lt $((shutdown_GPU_temp-30)) ]; then 
    if [ $current_speed6 -ne "65" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 5 -s 65
      current_speed6="65"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech6}${current_speed6}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_06" ] && [ "${GPU_name_06,,}" != "false" ] && [ $GPU_temp_06 -ge $((shutdown_GPU_temp-30)) ] && [ $GPU_temp_06 -lt $((shutdown_GPU_temp-25)) ]; then 
    if [ $current_speed6 -ne "70" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 5 -s 70
      current_speed6="70"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech6}${current_speed6}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_06" ] && [ "${GPU_name_06,,}" != "false" ] && [ $GPU_temp_06 -ge $((shutdown_GPU_temp-25)) ] && [ $GPU_temp_06 -lt $((shutdown_GPU_temp-20)) ]; then 
    if [ $current_speed6 -ne "75" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 5 -s 75
      current_speed6="75"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech6}${current_speed6}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_06" ] && [ "${GPU_name_06,,}" != "false" ] && [ $GPU_temp_06 -ge $((shutdown_GPU_temp-20)) ] && [ $GPU_temp_06 -lt $((shutdown_GPU_temp-15)) ]; then 
    if [ $current_speed6 -ne "80" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 5 -s 80
      current_speed6="80"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech6}${current_speed6}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_06" ] && [ "${GPU_name_06,,}" != "false" ] && [ $GPU_temp_06 -ge $((shutdown_GPU_temp-15)) ] && [ $GPU_temp_06 -lt $((shutdown_GPU_temp-10)) ]; then 
    if [ $current_speed6 -ne "85" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 5 -s 85
      current_speed6="85"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech6}${current_speed6}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_06" ] && [ "${GPU_name_06,,}" != "false" ] && [ $GPU_temp_06 -ge $((shutdown_GPU_temp-10)) ] && [ $GPU_temp_06 -lt $((shutdown_GPU_temp-5)) ]; then 
    if [ $current_speed6 -ne "90" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 5 -s 90
      current_speed6="90"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech6}${current_speed6}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_06" ] && [ "${GPU_name_06,,}" != "false" ] && [ $GPU_temp_06 -ge $((shutdown_GPU_temp-5)) ]; then
    if [ $current_speed6 -ne "95" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 5 -s 95
      current_speed6="95"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech6}${current_speed6}%..." | festival --tts; fi
    fi
  fi


  # GPU 07
  speech7="G. P. U... 7 fan is now... "
  if [ ! -z "$GPU_name_07" ] && [ "${GPU_name_07,,}" != "false" ] && [ $GPU_temp_07 -le $((shutdown_GPU_temp-45)) ]; then
    if [ $current_speed7 -ne "50" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 6 -s 50
      current_speed7="50"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech7}${current_speed7}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_07" ] && [ "${GPU_name_07,,}" != "false" ] && [ $GPU_temp_07 -ge $((shutdown_GPU_temp-40)) ] && [ $GPU_temp_07 -lt $((shutdown_GPU_temp-35)) ]; then 
    if [ $current_speed7 -ne "60" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 6 -s 60
      current_speed7="60"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech7}${current_speed7}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_07" ] && [ "${GPU_name_07,,}" != "false" ] && [ $GPU_temp_07 -ge $((shutdown_GPU_temp-35)) ] && [ $GPU_temp_07 -lt $((shutdown_GPU_temp-30)) ]; then 
    if [ $current_speed7 -ne "65" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 6 -s 65
      current_speed7="65"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech7}${current_speed7}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_07" ] && [ "${GPU_name_07,,}" != "false" ] && [ $GPU_temp_07 -ge $((shutdown_GPU_temp-30)) ] && [ $GPU_temp_07 -lt $((shutdown_GPU_temp-25)) ]; then 
    if [ $current_speed7 -ne "70" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 6 -s 70
      current_speed7="70"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech7}${current_speed7}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_07" ] && [ "${GPU_name_07,,}" != "false" ] && [ $GPU_temp_07 -ge $((shutdown_GPU_temp-25)) ] && [ $GPU_temp_07 -lt $((shutdown_GPU_temp-20)) ]; then 
    if [ $current_speed7 -ne "75" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 6 -s 75
      current_speed7="75"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech7}${current_speed7}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_07" ] && [ "${GPU_name_07,,}" != "false" ] && [ $GPU_temp_07 -ge $((shutdown_GPU_temp-20)) ] && [ $GPU_temp_07 -lt $((shutdown_GPU_temp-15)) ]; then 
    if [ $current_speed7 -ne "80" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 6 -s 80
      current_speed7="80"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech7}${current_speed7}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_07" ] && [ "${GPU_name_07,,}" != "false" ] && [ $GPU_temp_07 -ge $((shutdown_GPU_temp-15)) ] && [ $GPU_temp_07 -lt $((shutdown_GPU_temp-10)) ]; then 
    if [ $current_speed7 -ne "85" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 6 -s 85
      current_speed7="85"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech7}${current_speed7}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_07" ] && [ "${GPU_name_07,,}" != "false" ] && [ $GPU_temp_07 -ge $((shutdown_GPU_temp-10)) ] && [ $GPU_temp_07 -lt $((shutdown_GPU_temp-5)) ]; then 
    if [ $current_speed7 -ne "90" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 6 -s 90
      current_speed7="90"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech7}${current_speed7}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_07" ] && [ "${GPU_name_07,,}" != "false" ] && [ $GPU_temp_07 -ge $((shutdown_GPU_temp-5)) ]; then
    if [ $current_speed7 -ne "95" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 6 -s 95
      current_speed7="95"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech7}${current_speed7}%..." | festival --tts; fi
    fi
  fi


  # GPU 08
  speech8="G. P. U... 8 fan is now... "
  if [ ! -z "$GPU_name_08" ] && [ "${GPU_name_08,,}" != "false" ] && [ $GPU_temp_08 -le $((shutdown_GPU_temp-45)) ]; then
    if [ $current_speed8 -ne "50" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 67-s 50
      current_speed8="50"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech8}${current_speed8}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_08" ] && [ "${GPU_name_08,,}" != "false" ] && [ $GPU_temp_08 -ge $((shutdown_GPU_temp-40)) ] && [ $GPU_temp_08 -lt $((shutdown_GPU_temp-35)) ]; then 
    if [ $current_speed8 -ne "60" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 67-s 60
      current_speed8="60"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech8}${current_speed8}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_08" ] && [ "${GPU_name_08,,}" != "false" ] && [ $GPU_temp_08 -ge $((shutdown_GPU_temp-35)) ] && [ $GPU_temp_08 -lt $((shutdown_GPU_temp-30)) ]; then 
    if [ $current_speed8 -ne "65" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 67-s 65
      current_speed8="65"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech8}${current_speed8}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_08" ] && [ "${GPU_name_08,,}" != "false" ] && [ $GPU_temp_08 -ge $((shutdown_GPU_temp-30)) ] && [ $GPU_temp_08 -lt $((shutdown_GPU_temp-25)) ]; then 
    if [ $current_speed8 -ne "70" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 67-s 70
      current_speed8="70"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech8}${current_speed8}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_08" ] && [ "${GPU_name_08,,}" != "false" ] && [ $GPU_temp_08 -ge $((shutdown_GPU_temp-25)) ] && [ $GPU_temp_08 -lt $((shutdown_GPU_temp-20)) ]; then 
    if [ $current_speed8 -ne "75" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 67-s 75
      current_speed8="75"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech8}${current_speed8}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_08" ] && [ "${GPU_name_08,,}" != "false" ] && [ $GPU_temp_08 -ge $((shutdown_GPU_temp-20)) ] && [ $GPU_temp_08 -lt $((shutdown_GPU_temp-15)) ]; then 
    if [ $current_speed8 -ne "80" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 67-s 80
      current_speed8="80"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech8}${current_speed8}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_08" ] && [ "${GPU_name_08,,}" != "false" ] && [ $GPU_temp_08 -ge $((shutdown_GPU_temp-15)) ] && [ $GPU_temp_08 -lt $((shutdown_GPU_temp-10)) ]; then 
    if [ $current_speed8 -ne "85" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 67-s 85
      current_speed8="85"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech8}${current_speed8}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_08" ] && [ "${GPU_name_08,,}" != "false" ] && [ $GPU_temp_08 -ge $((shutdown_GPU_temp-10)) ] && [ $GPU_temp_08 -lt $((shutdown_GPU_temp-5)) ]; then 
    if [ $current_speed8 -ne "90" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 67-s 90
      current_speed8="90"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech8}${current_speed8}%..." | festival --tts; fi
    fi
  fi

  if [ ! -z "$GPU_name_08" ] && [ "${GPU_name_08,,}" != "false" ] && [ $GPU_temp_08 -ge $((shutdown_GPU_temp-5)) ]; then
    if [ $current_speed8 -ne "95" ]; then
      sudo -S "./amdgpu-pro-fans.sh" -a 67-s 95
      current_speed8="95"
      if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ]; then echo "${speech8}${current_speed8}%..." | festival --tts; fi
    fi
  fi


  # osd
  clear



  ######
  ######	VOCAL UPDATE
  ######	- read sensor temps every 30 min
  ######

  if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ] && [ $minute -eq "30" ] || [ $minute -eq "31" ] || [ $minute -eq "32" ] || [ $minute -eq "33" ] || [ $minute -eq "34" ] || [ $minute -eq "35" ] || [ $minute -eq "01" ] || [ $minute -eq "02" ] || [ $minute -eq "03" ] || [ $minute -eq "04" ] || [ $minute -eq "05" ] || [ $minute -eq "06" ]; then
    if [ $update_already_spoken = "false" ];then
      update_already_spoken="true"

      # intro
      random_update_string=$(printf 'up date... up date... up date...\nTime for another... up date... up date... up date...\nup date... up date... up date...\nHere comes another... up date... up date... up date...\nup date... up date... up date...\nattention... its... up date... up date... up date... time...\nup date... up date... up date...' | shuf -n1)
      echo "vocal update in progress..."
      sleep 1
      echo "$random_update_string" | festival --tts; random_update_string=""
      sleep 1

      # GPU temp 1
      if [ ! -z "$GPU_name_01" ] && [ "${GPU_name_01,,}" != "false" ] && [ $GPU_temp_01 -ge $((shutdown_GPU_temp-3)) ]; then echo "warning... G. P. U... 1 is running hot at $GPU_temp_01 degrees..." | festival --tts; fi
      if [ ! -z "$GPU_name_01" ] && [ "${GPU_name_01,,}" != "false" ] && [ $GPU_temp_01 -lt $((shutdown_GPU_temp-3)) ]; then echo "G. P. U... 1 is $GPU_temp_01 degrees..." | festival --tts; fi
      # GPU temp 2
      if [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ] && [ $GPU_temp_02 -ge $((shutdown_GPU_temp-3)) ]; then echo "warning... G. P. U... 2 is running hot at $GPU_temp_02 degrees..." | festival --tts; fi
      if [ ! -z "$GPU_name_02" ] && [ "${GPU_name_02,,}" != "false" ] && [ $GPU_temp_02 -lt $((shutdown_GPU_temp-3)) ]; then echo "G. P. U... 2 is $GPU_temp_02 degrees..." | festival --tts; fi
      # GPU temp 3
      if [ ! -z "$GPU_name_03" ] && [ "${GPU_name_03,,}" != "false" ] && [ $GPU_temp_03 -ge $((shutdown_GPU_temp-3)) ]; then echo "warning... G. P. U... 3 is running hot at $GPU_temp_03 degrees..." | festival --tts; fi
      if [ ! -z "$GPU_name_03" ] && [ "${GPU_name_03,,}" != "false" ] && [ $GPU_temp_03 -lt $((shutdown_GPU_temp-3)) ]; then echo "G. P. U... 3 is $GPU_temp_03 degrees..." | festival --tts; fi
      # GPU temp 4
      if [ ! -z "$GPU_name_04" ] && [ "${GPU_name_04,,}" != "false" ] && [ $GPU_temp_04 -ge $((shutdown_GPU_temp-3)) ]; then echo "warning... G. P. U... 4 is running hot at $GPU_temp_04 degrees..." | festival --tts; fi
      if [ ! -z "$GPU_name_04" ] && [ "${GPU_name_04,,}" != "false" ] && [ $GPU_temp_04 -lt $((shutdown_GPU_temp-3)) ]; then echo "G. P. U... 4 is $GPU_temp_04 degrees..." | festival --tts; fi
      # GPU temp 5
      if [ ! -z "$GPU_name_05" ] && [ "${GPU_name_05,,}" != "false" ] && [ $GPU_temp_05 -ge $((shutdown_GPU_temp-3)) ]; then echo "warning... G. P. U... 5 is running hot at $GPU_temp_05 degrees..." | festival --tts; fi
      if [ ! -z "$GPU_name_05" ] && [ "${GPU_name_05,,}" != "false" ] && [ $GPU_temp_05 -lt $((shutdown_GPU_temp-3)) ]; then echo "G. P. U... 5 is $GPU_temp_05 degrees..." | festival --tts; fi
      # GPU temp 6
      if [ ! -z "$GPU_name_06" ] && [ "${GPU_name_06,,}" != "false" ] && [ $GPU_temp_06 -ge $((shutdown_GPU_temp-3)) ]; then echo "warning... G. P. U... 6 is running hot at $GPU_temp_06 degrees..." | festival --tts; fi
      if [ ! -z "$GPU_name_06" ] && [ "${GPU_name_06,,}" != "false" ] && [ $GPU_temp_06 -lt $((shutdown_GPU_temp-3)) ]; then echo "G. P. U... 6 is $GPU_temp_06 degrees..." | festival --tts; fi
      # GPU temp 7
      if [ ! -z "$GPU_name_07" ] && [ "${GPU_name_07,,}" != "false" ] && [ $GPU_temp_07 -ge $((shutdown_GPU_temp-3)) ]; then echo "warning... G. P. U... 7 is running hot at $GPU_temp_07 degrees..." | festival --tts; fi
      if [ ! -z "$GPU_name_07" ] && [ "${GPU_name_07,,}" != "false" ] && [ $GPU_temp_07 -lt $((shutdown_GPU_temp-3)) ]; then echo "G. P. U... 7 is $GPU_temp_07 degrees..." | festival --tts; fi
      # GPU temp 8
      if [ ! -z "$GPU_name_08" ] && [ "${GPU_name_08,,}" != "false" ] && [ $GPU_temp_08 -ge $((shutdown_GPU_temp-3)) ]; then echo "warning... G. P. U... 8 is running hot at $GPU_temp_08 degrees..." | festival --tts; fi
      if [ ! -z "$GPU_name_08" ] && [ "${GPU_name_08,,}" != "false" ] && [ $GPU_temp_08 -lt $((shutdown_GPU_temp-3)) ]; then echo "G. P. U... 8 is $GPU_temp_08 degrees..." | festival --tts; fi
      # CPU temp
      if [ ! -z "$CPU_name" ] && [ "${CPU_name,,}" != "false" ] && [ $CPU_temp -ge $((shutdown_CPU_temp-3)) ]; then echo "warning... C. P. U... is running hot at $CPU_temp degrees..." | festival --tts; fi
      if [ ! -z "$CPU_name" ] && [ "${CPU_name,,}" != "false" ] && [ $CPU_temp -lt $((shutdown_CPU_temp-3)) ]; then echo "C. P. U... is $CPU_temp degrees..." | festival --tts; fi
      # AIO temp
      if [ ! -z "$AIO_name" ] && [ "${AIO_name,,}" != "false" ] && [ $AIO_temp -ge $((shutdown_AIO_temp-3)) ]; then echo "warning... A. I. O... is running hot at $CPU_temp degrees..." | festival --tts; fi
      if [ ! -z "$AIO_name" ] && [ "${AIO_name,,}" != "false" ] && [ $AIO_temp -lt $((shutdown_AIO_temp-3)) ]; then echo "A. I. O... is $AIO_temp degrees..." | festival --tts; fi

      # system reboot is required
      if [ -f "/var/run/reboot-required" ]; then
        echo "Ubuntu needs a reboot, please do this manually"
        echo "a manual system reboot is required to start using newly updated packages... consider configuring unattended upgrades to do this for you automatically..." | festival --tts
        sleep 2
      fi

      # system recovered from a shutdown
      if [ $was_shutdown = "true" ]; then echo "the system was recently suspended... temperatures were too high... relax... all hardware is safe and everything is back up and running..." | festival --tts; was_shutdown=""; fi    

      # next vocal update
      echo "the next voice update will be in 30... minutes..." | festival --tts
    fi
  fi

  # prepare for next vocal update
  if [ -f "/etc/festival.scm" ] && [ "${enable_speech,,}" = "true" ] && [ $minute != "30" ] && [ $minute != "31" ] && [ $minute != "32" ] && [ $minute != "33" ] && [ $minute != "34" ] && [ $minute != "35" ] && [ $minute != "01" ] && [ $minute != "02" ] && [ $minute != "03" ] && [ $minute != "04" ] && [ $minute != "05" ] && [ $minute != "06" ]; then
    if [ $update_already_spoken = "true" ]; then
      update_already_spoken="false"
    fi
  fi



  ######
  ######	OSD - DISPLAY THE CURRENT RESULTS
  ######	- display the hardware results
  ######

  # set the fan_percentage var to individually declare percentages for osd on this loop pass
  if [ "${GPU_name_01,,}" != "false" ]; then fan1="- ${current_speed1}%"; else fan1=""; fi
  if [ "${GPU_name_02,,}" != "false" ]; then fan2="- ${current_speed2}%"; else fan2=""; fi
  if [ "${GPU_name_03,,}" != "false" ]; then fan3="- ${current_speed3}%"; else fan3=""; fi
  if [ "${GPU_name_04,,}" != "false" ]; then fan4="- ${current_speed4}%"; else fan4=""; fi
  if [ "${GPU_name_05,,}" != "false" ]; then fan5="- ${current_speed5}%"; else fan5=""; fi
  if [ "${GPU_name_06,,}" != "false" ]; then fan6="- ${current_speed6}%"; else fan6=""; fi
  if [ "${GPU_name_07,,}" != "false" ]; then fan7="- ${current_speed7}%"; else fan7=""; fi
  if [ "${GPU_name_08,,}" != "false" ]; then fan8="- ${current_speed8}%"; else fan8=""; fi

  # osd
  clear
  echo -e -n "${bold}${Light_Cyan} - - - - - - - - - - - - - - -\n Automated Hardware Protection\n - - - - - - - - - - - - - - -${Default}${normal}

 ${Light_Gray}Suspend Computer Settings
 $GPU_user_setting $CPU_user_setting $AIO_user_setting

 ${Light_Gray}Current Sensor Temps
 $GPU_output_01 $fan1 $GPU_output_02 $fan2 $GPU_output_03 $fan3 $GPU_output_04 $fan4 $GPU_output_05 $fan5 $GPU_output_06 $fan6 $GPU_output_07 $fan7 $GPU_output_08 $fan8 $CPU_output $AIO_output

 ${Light_Gray}Other Settings
 $GPUclock_output $MEMclock_output $cache_output $suspend_output $connection_failed

"

  # osd - refresh countdown timer
  refresh_time=$((1 * 60))
  while [ $refresh_time -gt 0 ]; do
    echo -ne "${Light_Gray} Refreshing in ${refresh_time}s\033[0K\r"
    sleep 1
    : $((refresh_time--))
  done

  # clear PageCache, dentries and inodes daily - credit: Riyaj Shamsudeen, blog.pythian.com/performance-tuning-hugepages-in-linux
  if [ ! -z "$clear_caches" ] && [ "${clear_caches,,}" = "true" ]; then
    if [ $DAY = "Monday" ] && [ $monday_cache = "false" ]; then ${clear_the_caches}; monday_cache="true"; sunday_cache="false"; fi; if [ $DAY = "Tuesday" ] && [ $tuesday_cache = "false" ]; then ${clear_the_caches}; tuesday_cache="true"; monday_cache="false"; fi; if [ $DAY = "Wednesday" ] && [ $wednesday_cache = "false" ]; then ${clear_the_caches}; wednesday_cache="true"; tuesday_cache="false"; fi; if [ $DAY = "Thursday" ] && [ $thursday_cache = "false" ]; then ${clear_the_caches}; thurday_cache="true"; wednesday_cache="false"; fi; if [ $DAY = "Friday" ] && [ $friday_cache = "false" ]; then ${clear_the_caches}; friday_cache="true"; thurday_cache="false"; fi; if [ $DAY = "Saturday" ] && [ $saturday_cache = "false" ]; then ${clear_the_caches}; saturday_cache="true"; friday_cache="false"; fi; if [ $DAY = "Sunday" ] && [ $sunday_cache = "false" ]; then ${clear_the_caches}; sunday_cache="true"; saturday_cache="false"; fi  
  fi

  # osd
  clear

# /loop
done

# script failure
clear
echo "The script failed"
sleep 5
exit 0

