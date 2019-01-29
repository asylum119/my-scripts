#!/bin/sh

# upgrade xmrig | Brett Peters

echo "upgrading XMRig, Please wait"

# retrieve latest software version
XMRig_latest_version=$(wget -qO- 'https://github.com/xmrig/xmrig/releases/latest' | perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)\s*<\/title/si' | awk '{print $2}')

# change working directory
cd ~/Desktop

if [ ! -f "xmrig compiled/build/${XMRig_latest_version}" ]; then

  # clone the repo
  git clone https://github.com/xmrig/xmrig.git

  # make the compile build directory
  mkdir xmrig/build

  # version and donation code check
  if grep 'constexpr const int kDefaultDonateLevel =' "xmrig/src/donate.h" && grep 'constexpr const int kMinimumDonateLevel =' "xmrig/src/donate.h"; then

    # remove XMRig software donation (this is why we compile)
    sed -i '/kDefaultDonateLevel/c\constexpr const int kDefaultDonateLevel = 0;' xmrig/src/donate.h
    sed -i '/kMinimumDonateLevel/c\constexpr const int kMinimumDonateLevel = 0;' xmrig/src/donate.h

    # change working directory
    cd xmrig/build

    # compile
    cmake ..
    make

    # change working directory
    cd ~/Desktop

    # remove the current install
    if [ -d 'xmrig compiled' ]; then
      sudo rm -r 'xmrig compiled'
    fi

    # check the file structure exists
    if [ ! -d 'xmrig compiled' ]; then
      mkdir 'xmrig compiled'
    fi

    # copy the new install
    sudo cp -a 'xmrig/.' 'xmrig compiled'

    # save version number for update checking
    touch "xmrig compiled/build/${XMRig_latest_version}"

    # give new install higher permissions
    sudo chmod -R 777 'xmrig compiled/build'

    # clean up the compile files
    sudo rm -r 'xmrig'

    if [ -f "/etc/festival.scm" ]; then
      echo "C P U mining software has been compiled from the latest source code..." | festival --tts
    fi

    echo "Done"
    sleep 5

  else

    if [ -d "xmrig" ]; then
      rm -r "xmrig"
      echo "Failed to compile XMRig using upgrade script, donate code has changed, please manually edit the Sed command"
      sleep 5
      if [ -f "/etc/festival.scm" ]; then
        echo "Failed to compile X M R rig... using the upgrade script, donate code has changed, please manually edit the Sed command" | festival --tts
      fi
      touch "XMRig Upgrade.log"
      echo "Failed to compile XMRig using the upgrade script, XMRig donate code has changed. please manually edit the Sed command in the XMRig upgrade script" > "XMRig Upgrade.log"
    fi
  fi
fi

if [ -f "xmrig compiled/${XMRig_latest_version}" ] && [ -f "/etc/festival.scm" ]; then
  ehco "X M R rig is already the newest version" | festival --tts
  echo "XMRig is already the latest version"
  sleep 5
fi
