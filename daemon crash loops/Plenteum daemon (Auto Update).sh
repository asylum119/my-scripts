#!/bin/sh

# daemon update, load and crash loop | Brett Peters

# title
clear; PROMPT_COMMAND= ;echo "\033]0;Crypto Coin Plenteum - Daemon\a"; clear;

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
if [ -f 'wallet software/plenteum/plenteumd.log' ]; then
  rm 'wallet software/plenteum/plenteumd.log'
fi

# remove the old crash log file
if [ -f 'crashd.log' ]; then
  rm 'crashd.log'
fi

# check the latest version of software
echo "Checking for a newer software version"
sleep 3
latest_version=$(wget -qO- 'https://github.com/plenteum/plenteum/releases/latest' | perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)\s*<\/title/si' | awk '{print $2}')

# upgrade software
if [ ! -f "wallet software/plenteum/${latest_version}" ]; then
  echo " - upgrading software, please wait

  "
  cd "wallet software"
  wget https://github.com/plenteum/plenteum/releases/download/${latest_version}/plenteum-${latest_version}-linux.tar.gz
  if [ -d "plenteum" ];then
    rm -r "plenteum"
  fi
  tar -xvzf "plenteum-${latest_version}-linux.tar.gz"
  rm "plenteum-${latest_version}-linux.tar.gz"
  cp -a "plenteum-${latest_version}/." "plenteum"
  rm -r "plenteum-${latest_version}"
  touch "plenteum/${latest_version}"
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
echo "Starting the Plenteum daemon in a crash loop"
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
  'wallet software/plenteum/Plenteumd' --data-dir='blockchain/.Plenteum' --log-file 'plenteumd.log' --hide-my-port
  daemon_crash=$((daemon_crash+1)) 
done