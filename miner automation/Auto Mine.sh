#!/bin/sh

# load on system boot | Brett Peters

####
#### WAIT FOR CONNECTION
####

# say something
echo "initializing pleas wait..."
if [ -f "/etc/festival.scm" ]; then
  sleep 5; echo "the system has been started... please wait while I set everything up... this will take a while..." | festival --tts
fi

# check we have a connection before continuing
while true; do
ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && connection_test="pass" || connection_test="fail"
# we don't have a connection
if [ $connection_test = "fail" ] && [ -f "/etc/festival.scm" ]; then
  echo "Waiting on connection..." | festival --tts
  sleep 60
fi
# we have a connection so let the script continue
if [ $connection_test = "pass" ]; then
  break
fi
done

if [ -f "/etc/festival.scm" ]; then
  echo "connection has been established..." | festival --tts
fi


####
#### UPGRADE MINERS & LOAD HEAT PROTECTION
####

# change the working directory
cd '/home/brett/Desktop'

# upgrade XMRig
if [ ! -f "XMRig Upgrade.log" ]; then
  if [ -f "/etc/festival.scm" ]; then
    echo "checking for new CPU miner software..." | festival --tts
  fi
  sudo "./upgrade xmrig.sh"
else
  if [ -f "/etc/festival.scm" ]; then
    echo "CPU miner software not upgraded... the donate code has changed... please manually edit the sed command in the upgrade script and then delete the log file located on the desktop..." | festival --tts
  fi
fi

# upgrade XMRig-AMD
if [ ! -f "XMRig-amd Upgrade.log" ]; then
 if [ -f "/etc/festival.scm" ]; then
   echo "checking for new GPU miner software..." | festival --tts
 fi
  sudo "./upgrade xmrig-amd.sh"
else
  if [ -f "/etc/festival.scm" ]; then
    echo "GPU miner software was not upgraded... the donate code has changed... please manually edit the sed command in the upgrade script and then delete the log file located on the desktop..." | festival --tts
  fi
fi


####
#### LOAD SCRIPTS
####


#
#  CPU MINER
#

# load the CPU XMRig custom script in new terminal and position the window (bottom left)
if [ -f "/etc/festival.scm" ]; then
  echo "now loading the CPU miner..." | festival --tts
fi
cd '/home/brett/Desktop/xmrig scripts'

# Turtlecoin
#  gnome-terminal -e "./turtlecoin.sh" --geometry 95x26+0+999 &

  # Plentium
    gnome-terminal -e "./plenteum.sh" --geometry 95x26+0+999 &

sleep 130


#
#  HEAT PROTECTION
#

# start the heat protector custom script in new terminal and position the window (top left)
#! permissions added to "/etc/sudoers.d/brett" so load with root (sudo /path/to/script.sh)
if [ -f "/etc/festival.scm" ]; then
  echo "now loading hardware protection..." | festival --tts
fi
gnome-terminal -e "sudo /home/brett/Desktop/Heat-Protector-V2.sh" --geometry 73x31+0+0 &
sleep 20


#
#  GPU MINER
#

# load the GPU XMRig custom script in new terminal and position the window (top right)
if [ -f "/etc/festival.scm" ]; then
  echo "now loading the GPU miner..." | festival --tts
fi
cd '/home/brett/Desktop/xmrig-amd scripts'

# Turtlecoin
# gnome-terminal -e "./turtlecoin.sh" --geometry 95x26+999+0 &

  # Plentium
    gnome-terminal -e "./plenteum.sh" --geometry 95x26+999+0 &

sleep 10


#
# SPLASH
#

# load the splash screen
cd ~
gnome-terminal -e "./splash.sh"
sleep 3


