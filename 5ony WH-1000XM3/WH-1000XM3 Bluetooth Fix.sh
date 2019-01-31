#!/bin/sh

# GNU/Linux Sony WH-1000XM3 Bluetooth Fix | Brett Peters
# Credit: Martin Rosselle | martinrosselle.com/bluetooth-connectivity-issues-on-ubuntu-and-how-to-fix
#
# To manually undo
# "sudo nano /etc/bluetooth/main.conf" and remove the line "ControllerMode = bredr"


if [ -f "/etc/bluetooth/main.conf" ]; then
  echo "Script needs root for the following reasons
 - Updating Bluetooth config file
 - Restarting Bluetooth

"
  sudo echo ""

  if ! grep "ControllerMode = bredr'"; then
    sed -i '/#ControllerMode = dual/a ControllerMode = bredr' "/etc/bluetooth/main.conf"
    echo "Bluetooth config file was updated"
    sleep 2
    echo " Restarting the bluetooth service"
    sleep 2
    sudo /etc/init.d/bluetooth restart
    clear
    echo "done!"
    sleep 5
  else
    echo "Bluetooth config was already updated"
    sleep 2
    echo " - restarting bluetooth service"
    sleep 2
    sudo /etc/init.d/bluetooth restart
    clear
    echo "done!"
    sleep 5
  fi
else
  echo "Bluetooth config \"/etc/bluetooth/main.conf\" was not found"
  sleep 2
  echo "- soz, nothing I can do here"
  sleep 5
fi