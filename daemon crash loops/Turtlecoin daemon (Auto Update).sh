#!/bin/sh

# TurtleCoin Auto Upgrade (GNU/Linux Cli)
# - Upgrade TurtleCoin Software
# - Update TurtleCoin checkpoints file
# - load the TurtleCoin Daemon in a crash loop
#
# NOTE:
# - file structure is specific to my needs, you may want to adapt the code to suit
# - if loading constantly it may be a good idea to add a true/false variable for the checkpoints download
#
# Brett Peters
#

 
# title
clear; PROMPT_COMMAND= ;echo "\033]0;Crypto Coin TurtleCoin - Daemon\a"; clear

# check we have a connection before continuing
while true; do
ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null && connection_test="pass" || connection_test="fail"
# we don't have a connection
if [ $connection_test = "fail" ]; then
  clear
  echo "Waiting on connection..."
  sleep 60
fi
# we have a connection so continue
if [ $connection_test = "pass" ]; then
  break
fi
done

# remove the old log file
if [ -f 'wallet software/turtlecoin/turtlecoind.log' ]; then
  rm 'wallet software/turtlecoin/turtlecoind.log'
fi

# remove the old crash log file
if [ -f 'crashd.log' ]; then
  rm 'crashd.log'
fi

# remove the old wget log file
if [ -f 'wget-log' ]; then
  rm 'wget-log'
fi

# delete the old checkpoints file
if [ -f 'blockchain/turtlecoin/checkpoints.csv' ]; then
  rm 'blockchain/turtlecoin/checkpoints.csv' 
fi

# update checkpoints file
echo "Upgrading checkpoints file, please wait

"
# grab checkpoints file from IPFS gateway
wget "http://ns1.turtlecoin.lol/ipfs/QmYbHVXNJwLQHTptqoj5eX7wQi2hdMfxN6twCSrs1o2QwC" -O "blockchain/turtlecoin/checkpoints.csv"

echo "Checkpoints now updated"
sleep 3
clear


# check the latest version of software
echo "Checking for a newer software version"
sleep 3
latest_version=$(wget -qO- 'https://github.com/turtlecoin/turtlecoin/releases/latest' | perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)\s*<\/title/si' | awk '{print $2}')

# upgrade software
if [ ! -f "wallet software/turtlecoin/${latest_version}" ]; then
  echo " - upgrading software, please wait

  "
  cd "wallet software"
  wget https://github.com/turtlecoin/turtlecoin/releases/download/${latest_version}/turtlecoin-${latest_version}-linux.tar.gz
  if [ -d "turtlecoin" ];then
    rm -r "turtlecoin"
  fi
  tar -xvzf "turtlecoin-${latest_version}-linux.tar.gz"
  rm "turtlecoin-${latest_version}-linux.tar.gz"
  cp -a "turtlecoin-${latest_version}/." "turtlecoin"
  rm -r "turtlecoin-${latest_version}"
  touch "turtlecoin/${latest_version}"
  cd ..
  clear
  echo "Software now updated
  
  "
  sleep 3
  clear
else
  echo " - latest version detected"
  sleep 3
  clear
fi  
    
# start the daemon (inside crash loop and log how many times it crashes)
daemon_crash="0"
if [ "$daemon_crash" = "1" ]; then
  time_or_times="time"
else
  time_or_times="times"
fi
echo "Starting the Turtlecoin daemon in a crash loop"
sleep 3
clear
while true; do
  if [ "$daemon_crash" -gt "0" ]; then
    clear
    echo "Daemon just crashed, daemon has crashed $daemon_crash $time_or_times"
    echo `date` "- Latest daemon crash, daemon has crashed $daemon_crash $time_or_times since load" > crashd.log
    sleep 5
  fi
  clear
  'wallet software/turtlecoin/TurtleCoind' --data-dir='blockchain/turtlecoin' --log-file 'turtlecoind.log' --hide-my-port --load-checkpoints 'blockchain/turtlecoin/checkpoints.csv' 
  daemon_crash=$((daemon_crash+1)) 
  sleep 5
done
