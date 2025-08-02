# RPI Wi-Fi Honeypot

## RPI Wi-Fi Hacker Honeypot 
> simply deploy these example scripts to catch a Wi-Fi hacker attempting to hack your network, it logs their MAC address and more, it changes the Wi-Fi address to not only mock the hacker but proves that Wi-Fi script kiddies are out of their league when attempting to hack your Wi-Fi, and should stay away from your Wi-Fi network at all costs.
>
> ## RSPI Wi-Fi Honeypot
> having fun with wanna be Wi-Fi hackers
>
> ## Introduction

> RPI Fake Wi-Fi AP with dynamic updating SSID broadcast on connection attempt, MAC logging for connection attempts, random AP MAC broadcast and chanel broadcast number for limiting a single point of attack.

> If you have a RPI and want to broadcast Wi-Fi to totarget Wi-Fi Neirbour hacking and haggle the hacker then this might be for you.
>
> Loga ALL connection attempts to a bogus wifi network and choose between several scripts to let the hacker know that you are on to them. log their Mac address and more...


Hammered this out quickly when next door deployed a script kiddie mobile phone app pineapple attack to target my Wi-Fi. they quickly found out that their device address (Mac address) was now in my hands.

TIP: hostapd was not intended for dynamic updating so keep the service restarts. 

see <a href="https://github.com/asylum119/my-scripts/blob/master/RPI%20Wi-Fi%20Honeypot/honeypot/script/hacker-challenge.sh">Hacker challenge script</a> for example of dynamic SSID updating. 

## Installation

> See Build.html
