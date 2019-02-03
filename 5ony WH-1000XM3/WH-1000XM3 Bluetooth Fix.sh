#!/bin/sh

# GNU/Linux Sony WH-1000XM3 Bluetooth Fix | Brett Peters
# Credits: 
#
# Bluetooth Pairing
# Martin Rosselle | martinrosselle.com/bluetooth-connectivity-issues-on-ubuntu-and-how-to-fix
#
# Headphone Bluetooth High Fidelity By Default
# Jean David | medium.com/@overcode/fixing-bluetooth-in-ubuntu-pop-os-18-04-d4b8dbf7ddd6
#
# To manually undo
# "sudo nano /etc/bluetooth/main.conf" and remove the line "ControllerMode = bredr"
# "sudo nano /etc/bluetooth/main.conf" and remove the line "Enable=Source,Sink,Media,Socket"


if [ -f "/etc/bluetooth/main.conf" ]; then
  echo "Script needs root for the following reasons
 - Updating Bluetooth config file
 - Restarting Bluetooth

"
  sudo echo ""

  # WH-1000XM3 Pairing
  if ! grep -q "ControllerMode = bredr" "/etc/bluetooth/main.conf"; then
    sudo sed -i '/#ControllerMode = dual/a ControllerMode = bredr' "/etc/bluetooth/main.conf"
    echo "Bluetooth config file was updated for pairing"
    sleep 2
    echo " - Restarting the bluetooth service"
    sleep 2
    sudo service bluetooth restart
    sleep 2
  else
    echo "Bluetooth config was already updated for pairing"
    sleep 2
    clear
  fi
  # WH-1000XM3 High Fidelity
  if ! grep -q "Enable=Source,Sink,Media,Socket" "/etc/bluetooth/main.conf"; then
    sudo sed -i '/General/a Enable=Source,Sink,Media,Socket' "/etc/bluetooth/main.conf"
    echo "Bluetooth config file was updated for High Fidelity"
    sleep 2
    echo " - Restarting the bluetooth service"
    sleep 2
    sudo service bluetooth restart
    sleep 2
  else
    echo "Bluetooth config was already updated for High Fidelity"
    sleep 2
    clear
  fi
  echo "done"
  sleep 5
else
  echo "Bluetooth config \"/etc/bluetooth/main.conf\" was not found"
  sleep 2
  echo "- soz, nothing I can do here"
  sleep 5
fi
