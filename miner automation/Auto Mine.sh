#!/bin/sh

# load on system boot | Brett Peters

#
# select what coin to mine on boot
#

# - turtlecoin, plenteum, xcash, aeon
# - citicash, graft, italocoin, solacecoin
# - sumokoin, worktips, bbsCoin, elya
# - iridium, niobio, stellite, xaria

coin_to_mine="xcash"




####
#### WAIT FOR CONNECTION
####

# say something
echo "initializing pleas wait..."
if [ -f "/etc/festival.scm" ]; then
  sleep 5; echo "the system has been started... please wait while I set everything up... this will take a while..." | festival --tts
fi

# check connection
while true; do
ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && connection_test="pass" || connection_test="fail"
# we don't have a connection
if [ $connection_test = "fail" ] && [ -f "/etc/festival.scm" ]; then
  echo "Waiting on connection..." | festival --tts
  sleep 60
fi
# have connection
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


# make sure the user var has no caps 
mine_this=$(echo "$coin_to_mine" | tr '[:upper:]' '[:lower:]')


#
#  CPU MINER
#

# load the CPU XMRig custom script in new terminal and position the window (bottom left)
if [ -f "/etc/festival.scm" ]; then
  echo "now loading the CPU miner..." | festival --tts
fi

cd '/home/brett/Desktop/xmrig scripts'

# Turtlecoin
if [ "$mine_this" = "turtlecoin" ]; then
  sleep 60
  gnome-terminal -e "./turtlecoin.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# Plentium
if [ "$mine_this" = "plenteum" ]; then
  sleep 60
 gnome-terminal -e "./plenteum.sh" --geometry 95x26+0+999 &
 sleep 60
fi

# xcash
if [ "$mine_this" = "xcash" ]; then
  sleep 60
  gnome-terminal -e "./xCash.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# aeon
if [ "$mine_this" = "aeon" ]; then
  sleep 60
  gnome-terminal -e "./aeon.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# citicash
if [ "$mine_this" = "citicash" ]; then
  sleep 60
  gnome-terminal -e "./CitiCash.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# graft
if [ "$mine_this" = "graft" ]; then
  sleep 60
  gnome-terminal -e "./graft.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# italocoin
if [ "$mine_this" = "italocoin" ]; then
  sleep 60
  gnome-terminal -e "./italocoin.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# solacecoin
if [ "$mine_this" = "solacecoin" ]; then
  sleep 60
  gnome-terminal -e "./solacecoin.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# sumokoin
if [ "$mine_this" = "sumokoin" ]; then
  sleep 60
  gnome-terminal -e "./sumokoin.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# worktips
if [ "$mine_this" = "worktips" ]; then
  sleep 60
  gnome-terminal -e "./worktips.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# bbsCoin
if [ "$mine_this" = "bbsCoin" ]; then
  sleep 60
  gnome-terminal -e "./BBSCoin.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# elya
if [ "$mine_this" = "elya" ]; then
  sleep 60
  gnome-terminal -e "./elya.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# iridium
if [ "$mine_this" = "iridium" ]; then
  sleep 60
  gnome-terminal -e "./iridium.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# niobio
if [ "$mine_this" = "niobio" ]; then
  sleep 60
  gnome-terminal -e "./Niobio.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# stellite
if [ "$mine_this" = "stellite" ]; then
  sleep 60
  gnome-terminal -e "./stellite.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# xaria
if [ "$mine_this" = "xaria" ]; then
  sleep 60
  gnome-terminal -e "./xaria.sh" --geometry 95x26+0+999 &
  sleep 60
fi



#
#  HEAT PROTECTION
#

if [ -f "/etc/festival.scm" ]; then
  echo "now loading hardware protection..." | festival --tts
fi

# start the heat protector custom script in new terminal and position the window (top left)
#! permissions added to "/etc/sudoers.d/brett" so load with root (sudo /path/to/script.sh)
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
if [ "$mine_this" = "turtlecoin" ]; then
  gnome-terminal -e "./turtlecoin.sh" --geometry 95x26+999+0 &
  sleep 30
fi

# Plentium
if [ "$mine_this" = "plenteum" ]; then
  gnome-terminal -e "./plenteum.sh" --geometry 95x26+999+0 &
  sleep 30
fi

# Xcash
if [ "$mine_this" = "xcash" ]; then
  gnome-terminal -e "./xCash.sh" --geometry 95x26+999+0 &
  sleep 30
fi

# aeon
if [ "$mine_this" = "aeon" ]; then
  sleep 60
  gnome-terminal -e "./aeon.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# citicash
if [ "$mine_this" = "citicash" ]; then
  sleep 60
  gnome-terminal -e "./CitiCash.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# graft
if [ "$mine_this" = "graft" ]; then
  sleep 60
  gnome-terminal -e "./graft.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# italocoin
if [ "$mine_this" = "italocoin" ]; then
  sleep 60
  gnome-terminal -e "./italocoin.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# solacecoin
if [ "$mine_this" = "solacecoin" ]; then
  sleep 60
  gnome-terminal -e "./solacecoin.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# sumokoin
if [ "$mine_this" = "sumokoin" ]; then
  sleep 60
  gnome-terminal -e "./sumokoin.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# worktips
if [ "$mine_this" = "worktips" ]; then
  sleep 60
  gnome-terminal -e "./worktips.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# bbsCoin
if [ "$mine_this" = "bbsCoin" ]; then
  sleep 60
  gnome-terminal -e "./BBSCoin.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# elya
if [ "$mine_this" = "elya" ]; then
  sleep 60
  gnome-terminal -e "./elya.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# iridium
if [ "$mine_this" = "iridium" ]; then
  sleep 60
  gnome-terminal -e "./iridium.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# niobio
if [ "$mine_this" = "niobio" ]; then
  sleep 60
  gnome-terminal -e "./Niobio.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# stellite
if [ "$mine_this" = "stellite" ]; then
  sleep 60
  gnome-terminal -e "./stellite.sh" --geometry 95x26+0+999 &
  sleep 60
fi

# xaria
if [ "$mine_this" = "xaria" ]; then
  sleep 60
  gnome-terminal -e "./xaria.sh" --geometry 95x26+0+999 &
  sleep 60
fi


#
# SPLASH
#

# load the splash screen
cd ~
gnome-terminal -e "./splash.sh"
sleep 3
