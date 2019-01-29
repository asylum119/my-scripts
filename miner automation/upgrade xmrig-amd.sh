#!/bin/sh

# upgrade xmrig-amd | Brett Peters

echo "upgrading XMRig-AMD, Please wait"

# retrieve latest software version
XMRigAMD_latest_version=$(wget -qO- 'https://github.com/xmrig/xmrig-amd/releases/latest' | perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)\s*<\/title/si' | awk '{print $2}')

# change working directory
cd ~/Desktop

if [ ! -f "xmrig-amd compiled/build/${XMRigAMD_latest_version}" ]; then

  # clone the repo
  git clone https://github.com/xmrig/xmrig-amd.git

  # make the build directory
  mkdir "xmrig-amd/build"

  # version and donation code check
  if grep 'constexpr const int kDefaultDonateLevel =' "xmrig-amd/src/donate.h" && grep 'constexpr const int kMinimumDonateLevel =' "xmrig-amd/src/donate.h"; then

    # remove XMRig software donation (this is why we compile)
    sed -i '/kDefaultDonateLevel/c\constexpr const int kDefaultDonateLevel = 0;' xmrig-amd/src/donate.h
    sed -i '/kMinimumDonateLevel/c\constexpr const int kMinimumDonateLevel = 0;' xmrig-amd/src/donate.h

    # change working directory
    cd xmrig-amd/build

    # compile
    cmake ..
    make

    # change working directory
    cd ~/Desktop

    # remove the current install
    if [ -d 'xmrig-amd compiled' ]; then
      sudo rm -r 'xmrig-amd compiled'
    fi

    # check the file structure exists
    if [ ! -d 'xmrig-amd compiled' ]; then
      mkdir 'xmrig-amd compiled'
    fi

    # copy the new install
    sudo cp -a 'xmrig-amd/.' 'xmrig-amd compiled'

    # save version number for update checking
    touch "xmrig-amd compiled/build/${XMRigAMD_latest_version}"

    # give new install higher permissions
    sudo chmod -R 777 'xmrig-amd compiled/build'

    # clean up the compile files
    sudo rm -r 'xmrig-amd'

    if [ -f "/etc/festival.scm" ]; then
      echo "A M D mining software has been compiled from the latest source code..." | festival --tts
    fi

    echo "Done"
    sleep 5

  else

    if [ -d "xmrig-amd" ]; then
      rm -r "xmrig-amd"
      echo "Failed to compile XMRig-amd using upgrade script, donate code has changed, please manually edit the Sed command"
      sleep 5
      if [ -f "/etc/festival.scm" ]; then
        echo "Failed to compile X. M. R. rig... A. M. D. using the upgrade script, donate code has changed, please manually edit the Sed command" | festival --tts
      fi
      touch "XMRig-amd Upgrade.log"
      echo "Failed to compile XMRig-amd using the upgrade script, XMRig-amd donate code has changed. Please manually edit the Sed command in the XMRig-amd upgrade script" > "XMRig-amd Upgrade.log"
    fi
  fi
fi

if [ -f "xmrig-amd compiled/${XMRigAMD_latest_version}" ] && [ -f "/etc/festival.scm" ]; then
  ehco "X M R rig A M D is already the newest version" | festival --tts
  echo "XMRig-AMD is already the latest version"
  sleep 5
fi
