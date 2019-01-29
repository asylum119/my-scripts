#!/bin/sh

# upgrade xmr-stak | Brett Peters

echo "upgrading xmr-stak, Please wait"

# retrieve latest software version
XMR_STAK_latest_version=$(wget -qO- 'https://github.com/fireice-uk/xmr-stak/releases/latest' | perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)\s*<\/title/si' | sed 's/·.*//')

# change working directory
cd ~/Desktop

if [ ! -f 'xmr-stak compiled/build/'"${XMR_STAK_latest_version}" ]; then

  # download the git repository
  git clone https://github.com/fireice-uk/xmr-stak.git

  # version and donation code check
  if grep 'constexpr double fDevDonationLevel =' "xmr-stak/xmrstak/donate-level.hpp"; then

    # remove xmr-stak software donation (this is why we compile)
    sed -i '/fDevDonationLevel/c\constexpr double fDevDonationLevel = 0.0 / 100.0;' 'xmr-stak/xmrstak/donate-level.hpp'

    # create a compile directory
    mkdir xmr-stak/build

    # change working directory
    cd xmr-stak/build

    # compile xmr-stak (without nvidia GPU support)
    cmake .. -DCUDA_ENABLE=OFF
    make install

    # change working directory
    cd ~/Desktop

    # remove the current install
    if [ -d 'xmr-stak compiled' ]; then
      sudo rm -r 'xmr-stak compiled'
    fi

    # check the file structure exists
    if [ ! -d 'xmr-stak compiled' ]; then
      mkdir 'xmr-stak compiled'
    fi

    # copy the new install
    sudo cp -a 'xmr-stak/.' 'xmr-stak compiled'

    # save version number for update checking
    touch "xmr-stak compiled/build/${XMR_STAK_latest_version}"

    # give new install higher permissions
    sudo chmod -R 777 'xmr-stak compiled/build'

    # clean up the compile files
    sudo rm -r 'xmr-stak'

    if [ -f "/etc/festival.scm" ]; then
      echo "Duel mining software has been compiled from the latest source code..." | festival --tts
    fi

    echo "Done"
    sleep 5

  else

    if [ -d "xmr-stak" ]; then
      rm -r "xmr-stak"
      echo "Failed to compile XMR STAK using upgrade script, donate code has changed, please manually edit the Sed command"
      sleep 5
      if [ -f "/etc/festival.scm" ]; then
        echo "Failed to compile XMR STAK... using the upgrade script, donate code has changed, please manually edit the Sed command" | festival --tts
      fi
      touch "XMR STAK Upgrade.log"
      echo "Failed to compile XMR STAK using the upgrade script, XMR STAK donate code has changed. please manually edit the Sed command in the XMR STAK upgrade script" > "XMR-STAK Upgrade.log"
    fi
  fi
fi

if [ -f "XMR STAK compiled/${XMR_STAK_latest_version}" ] && [ -f "/etc/festival.scm" ]; then
  ehco "XMR STAK is already the newest version" | festival --tts
  echo "XMR STAK is already the latest version"
  sleep 5
fi
