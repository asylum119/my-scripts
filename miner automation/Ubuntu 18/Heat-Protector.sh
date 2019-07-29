#!/bin/bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# WARNING! This script is for advanced users and released for peer review only. Your System, Your Hardware... Your responsibility.
#
# This script is loaded by the automated mining script that is loaded on boot
# and dynamically changes GPU fan speeds % to suit individual GPU temperature.
#
# see the "miner setup" file and make sure that both Auto-Mine.sh & Heat-Protector.sh
# are added to the sudoers file, this script needs sudo for rocm-smi & rtcwake
#
# The system will suspend if CPU, AIO or GPU temp gets to high then resume the
# system and continue previous operations when temps are again reasonable
#
# GPU fan speeds are controlled via the ROCm SMI Tool, sensors commands may
# need editing for a different machine and or sensors package Version
#
# Operating System: Ubuntu 18 Bionic
# DEPENDENCIES: lm-sensors, ROCm Driver / ROCm SMI
# CPU: Threadripper - AMD
# GPU: RX580 8G - AMD
#
# Brett Peters, asylum119 - github.com/asylum119
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#
# SET THE TEMPERATURE LIMITS (°C) FOR CPU, GPU AND AIO
# - the computer should suspend when a temp setting is reached.
# ! WARNING: these values should be a safe operating temp to limit critical hardware failure.
# - monitor remotly via SSH "while true; do clear; sensors | grep Tdie; sensors | grep edge; sleep 60; done"

  # MAX GPU Temp
  shutdown_GPU_temp="75"


  # MAX CPU Temp
  shutdown_CPU_temp="75"


  # MAX AIO Temp
  shutdown_AIO_temp="75"



#
# SET THE GPU NAMES
# - in terminal type "sensors" and enter all of the GPU names you find here and leave the rest blank
# - if using older sensors package then "edge" in this code will need changing to "temp1"

  # GPU Names
  GPU_name_01="amdgpu-pci-4100"
  GPU_name_02="amdgpu-pci-0a00"


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
    # SET THE OVERHEAT SUSPEND TIME
    # - set the amount of time in seconds to resume after a computer shutdown caused by high hardware temperatures
    # - not recommended to go under 1Hr (we want to limit multiple shutdowns on hot days to protect expensive hardware)
    #

    # suspend time
    suspend_time="14400" # 1Hr "3600", 2Hr "7200", 3Hr "10800", 4Hr "14400"


    # DEPRECIATED:
    # - TODO: update for ROCm-SMI
    # SET THE GPU FREQUENCY IN MHz
    # - WARNING! only tested on RX580s
    # - this is good for underclocking AMD RX GPUs using the AMD-GPU-PRO Driver
    # - set to "False" (default) to not alter the GPU frequency
    #

    # GPU frequency
    #gpuClock_frequency="1300" # "300", "600", "900", "1145", "1215", "1257", "1300", "1340", "False"



    # DEPRECIATED:
    # - TODO: update for ROCm-SMI
    # SET THE GPU MEMCLOCK FREQUENCY IN MHz
    # - WARNING! only tested on RX580s
    # - this is good for underclocking AMD RX GPUs using the AMD-GPU-PRO Driver
    # - set to "False" (default) to not alter the memclock frequency
    #

    # memclock frequency
    #memClock_frequency="1000" # "300", "1000", "2000", "False"



#
# REBOOT THE SYSTEM
# - enabling this will reboot the system (handy if Ubuntu upgrades packages and requires a reboot)
# - this can be set to "False" if your Ubuntu system does not automatically update packages or security updates
# - set to "True" to enable | "False" to disable
#

  # reboot if Ubuntu needs it
  system_reboot="True"







# - - S - T - A - R - T - - T - H - E - - S - C - R - I - P - T - - - >


######
######	STARTUP ENVIRONMENT
######	- before we run the script
######


# script location
SCRIPT="$0"

# working directory
cd ~
cd Desktop

# start gpu fans at 95% to avoid an initial high reading
sudo -S "/opt/rocm/bin/rocm-smi" --setfan 95%
current_speed="95"
if [[ ! -z "$GPU_name_01" ]]; then current_speed1="95"; else current_speed1="0"; fi
if [[ ! -z "$GPU_name_02" ]]; then current_speed2="95"; else current_speed2="0"; fi


# allow time for initial GPU cooling
sleep 10




######
######	LOOP
######	- infinite loop
######

while true; do


  ######
  ######	SUSPEND
  ######	- read sensor temps and suspend if hardware gets too hot
  ######

  # time to blast GPU fans at max after system wake
  wakeup_cool_time="30"

  # GPU 01
  if [[ ! -z "${GPU_name_01}" ]]; then
    # stats
    GPU_temp_01=$(sensors | sed -e "6,/${GPU_name_01}/d" | grep -m 1 edge | awk '{print $2}' | cut -c 2-3)
    GPU_fan_speed_01=$(sensors | sed -e "5,/${GPU_name_01}/d" | grep -m 1 fan | awk '{print $2}')
    # suspend and set cool down time after wake
    if [[ "$GPU_temp_01" -ge "$shutdown_GPU_temp" ]]; then
      sudo -S /usr/sbin/rtcwake -m mem -s $suspend_time; sleep $wakeup_cool_time; was_shutdown="true"
    fi
  fi

  # GPU 02
  if [[ ! -z "${GPU_name_02}" ]]; then
    # stats
    GPU_temp_02=$(sensors | sed -e "6,/${GPU_name_02}/d" | grep -m 1 edge | awk '{print $2}' | cut -c 2-3)
    GPU_fan_speed_02=$(sensors | sed -e "5,/${GPU_name_02}/d" | grep -m 1 fan | awk '{print $2}')
    # suspend and set cool down time after wake
    if [[ "$GPU_temp_02" -ge "$shutdown_GPU_temp" ]]; then
      sudo -S /usr/sbin/rtcwake -m mem -s $suspend_time; sleep $wakeup_cool_time; was_shutdown="true"
    fi
  fi


  # CPU
  if [[ ! -z "${CPU_name}" ]]; then
    # stats
    CPU_temp=$(sensors | sed -e "1,/${CPU_name}/d" | grep -m 1 Tdie | awk '{print $2}' | cut -c 2-3)
    CPU_high_temp=$(sensors | sed -e "1,/${CPU_name}/d" | grep -m 1 Tdie | awk '{print $5}' | cut -c 2-3)
    # suspend and set cool down time after wake
    if [[ "$CPU_temp" -ge "$CPU_high_temp" ]]; then
      sudo -S /usr/sbin/rtcwake -m mem -s $suspend_time; sleep $wakeup_cool_time; was_shutdown="true"
    fi
  fi

  # AIO
  if [[ ! -z "${AIO_name}" ]] && [[ ! -z "${CPU_name}" ]]; then
    # stats
    AIO_temp=$(sensors | sed -e "1,/${AIO_name}/d" | grep -m 1 Tdie | awk '{print $2}' | cut -c 2-3)
    AIO_high_temp=$(sensors | sed -e "1,/${AIO_name}/d" | grep -m 1 Tdie | awk '{print $5}' | cut -c 2-3)
    # suspend and set cool down time after wake
    if [[ "$AIO_temp" -ge "$AIO_high_temp" ]]; then
      sudo -S /usr/sbin/rtcwake -m mem -s $suspend_time; sleep $wakeup_cool_time; was_shutdown="true"
    fi
  fi




  ######
  ######	GPU FAN CONTROL AUTOMATION
  ######	- adjust the gpu fan speeds (with "shutdown_GPU_temp" being the high temp setting)
  ######

  # ! WARNING: 50% is lowest fan speed before GPU warning | 95% is highest fan speed before GPU warning

  # GPU 01
  if [[ ! -z "$GPU_name_01" ]] && [[ $GPU_temp_01 -lt $((shutdown_GPU_temp-45)) ]]; then
    if [[ $current_speed1 -ne "50" ]]; then
      sudo -S "/opt/rocm/bin/rocm-smi" --setfan 40% -d 0; sleep 5
      current_speed1="50"
    fi
  fi

  if [[ ! -z "$GPU_name_01" ]] && [[ $GPU_temp_01 -ge $((shutdown_GPU_temp-40)) ]] && [[ $GPU_temp_01 -lt $((shutdown_GPU_temp-35)) ]]; then 
    if [[ $current_speed1 -ne "60" ]]; then
      sudo -S "/opt/rocm/bin/rocm-smi" --setfan 60% -d 0; sleep 5
      current_speed1="60"
    fi
  fi

  if [[ ! -z "$GPU_name_01" ]] && [[ $GPU_temp_01 -ge $((shutdown_GPU_temp-35)) ]] && [[ $GPU_temp_01 -lt $((shutdown_GPU_temp-30)) ]]; then 
    if [[ $current_speed1 -ne "65" ]]; then
      sudo -S "/opt/rocm/bin/rocm-smi" --setfan 65% -d 0; sleep 5
      current_speed1="65"
    fi
  fi

  if [[ ! -z "$GPU_name_01" ]] && [[ $GPU_temp_01 -ge $((shutdown_GPU_temp-30)) ]] && [[ $GPU_temp_01 -lt $((shutdown_GPU_temp-25)) ]]; then 
    if [[ $current_speed1 -ne "70" ]]; then
      sudo -S "/opt/rocm/bin/rocm-smi" --setfan 70% -d 0; sleep 5
      current_speed1="70"
    fi
  fi

  if [[ ! -z "$GPU_name_01" ]] && [[ $GPU_temp_01 -ge $((shutdown_GPU_temp-25)) ]] && [[ $GPU_temp_01 -lt $((shutdown_GPU_temp-20)) ]]; then 
    if [[ $current_speed1 -ne "75" ]]; then
      sudo -S "/opt/rocm/bin/rocm-smi" --setfan 75% -d 0; sleep 5
      current_speed1="75"
    fi
  fi

  if [[ ! -z "$GPU_name_01" ]] && [[ $GPU_temp_01 -ge $((shutdown_GPU_temp-20)) ]] && [[ $GPU_temp_01 -lt $((shutdown_GPU_temp-15)) ]]; then
    if [[ $current_speed1 -ne "80" ]]; then
      sudo -S "/opt/rocm/bin/rocm-smi" --setfan 80% -d 0; sleep 5
      current_speed1="80"
    fi
  fi

  if [[ ! -z "$GPU_name_01" ]] && [[ $GPU_temp_01 -ge $((shutdown_GPU_temp-15)) ]] && [[ $GPU_temp_01 -lt $((shutdown_GPU_temp-10)) ]]; then 
    if [[ $current_speed1 -ne "85" ]]; then
      sudo -S "/opt/rocm/bin/rocm-smi" --setfan 85% -d 0; sleep 5
      current_speed1="85"
    fi
  fi

  if [[ ! -z "$GPU_name_01" ]] && [[ $GPU_temp_01 -ge $((shutdown_GPU_temp-10)) ]] && [[ $GPU_temp_01 -lt $((shutdown_GPU_temp-5)) ]]; then 
    if [[ $current_speed1 -ne "90" ]]; then
      sudo -S "/opt/rocm/bin/rocm-smi" --setfan 90% -d 0; sleep 5
      current_speed1="90"
    fi
  fi

  if [[ ! -z "$GPU_name_01" ]] && [[ $GPU_temp_01 -ge $((shutdown_GPU_temp-5)) ]]; then
    if [[ $current_speed1 -ne "95" ]]; then
      sudo -S "/opt/rocm/bin/rocm-smi" --setfan 95% -d 0; sleep 5
      current_speed1="95"
    fi
  fi

  # GPU 02
  if [[ ! -z "$GPU_name_02" ]] && [[ $GPU_temp_02 -le $((shutdown_GPU_temp-45)) ]]; then
    if [[ $current_speed2 -ne "50" ]]; then
      sudo -S "/opt/rocm/bin/rocm-smi" --setfan 40% -d 1; sleep 5
      current_speed2="50"
    fi
  fi

  if [[ ! -z "$GPU_name_02" ]] && [[ $GPU_temp_02 -ge $((shutdown_GPU_temp-40)) ]] && [[ $GPU_temp_02 -lt $((shutdown_GPU_temp-35)) ]]; then 
    if [[ $current_speed2 -ne "60" ]]; then
      sudo -S "/opt/rocm/bin/rocm-smi" --setfan 60% -d 1; sleep 5
      current_speed2="60"
    fi
  fi

  if [[ ! -z "$GPU_name_02" ]] && [[ $GPU_temp_02 -ge $((shutdown_GPU_temp-35)) ]] && [[ $GPU_temp_02 -lt $((shutdown_GPU_temp-30)) ]]; then 
    if [[ $current_speed2 -ne "65" ]]; then
      sudo -S "/opt/rocm/bin/rocm-smi" --setfan 65% -d 1; sleep 5
      current_speed2="65"
    fi
  fi

  if [[ ! -z "$GPU_name_02" ]] && [[ $GPU_temp_02 -ge $((shutdown_GPU_temp-30)) ]] && [[ $GPU_temp_02 -lt $((shutdown_GPU_temp-25)) ]]; then 
    if [[ $current_speed2 -ne "70" ]]; then
      sudo -S "/opt/rocm/bin/rocm-smi" --setfan 70% -d 1; sleep 5
      current_speed2="70"
    fi
  fi

  if [[ ! -z "$GPU_name_02" ]] && [[ $GPU_temp_02 -ge $((shutdown_GPU_temp-25)) ]] && [[ $GPU_temp_02 -lt $((shutdown_GPU_temp-20)) ]]; then 
    if [[ $current_speed2 -ne "75" ]]; then
      sudo -S "/opt/rocm/bin/rocm-smi" --setfan 75% -d 1; sleep 5
      current_speed2="75"
    fi
 fi

  if [[ ! -z "$GPU_name_02" ]] && [[ $GPU_temp_02 -ge $((shutdown_GPU_temp-20)) ]] && [[ $GPU_temp_02 -lt $((shutdown_GPU_temp-15)) ]]; then 
    if [[ $current_speed2 -ne "80" ]]; then
      sudo -S "/opt/rocm/bin/rocm-smi" --setfan 80% -d 1; sleep 5
      current_speed2="80"
    fi
  fi

  if [[ ! -z "$GPU_name_02" ]] && [[ $GPU_temp_02 -ge $((shutdown_GPU_temp-15)) ]] && [[ $GPU_temp_02 -lt $((shutdown_GPU_temp-10)) ]]; then 
    if [[ $current_speed2 -ne "85" ]]; then
      sudo -S "/opt/rocm/bin/rocm-smi" --setfan 85% -d 1; sleep 5
      current_speed2="85"
    fi
  fi

  if [[ ! -z "$GPU_name_02" ]] && [[ $GPU_temp_02 -ge $((shutdown_GPU_temp-10)) ]] && [[ $GPU_temp_02 -lt $((shutdown_GPU_temp-5)) ]]; then 
    if [[ $current_speed2 -ne "90" ]]; then
      sudo -S "/opt/rocm/bin/rocm-smi" --setfan 90% -d 1; sleep 5
      current_speed2="90"
    fi
  fi

  if [[ ! -z "$GPU_name_02" ]] && [[ $GPU_temp_02 -ge $((shutdown_GPU_temp-5)) ]]; then
    if [[ $current_speed2 -ne "95" ]]; then
      sudo -S "/opt/rocm/bin/rocm-smi" --setfan 95% -d 1; sleep 5
      current_speed2="95"
    fi
  fi


# slow the loop down
sleep 20


# /loop
done
