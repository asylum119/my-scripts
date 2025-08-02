# RPI Wi-Fi Honeypot

## Introduction

> RPI Fake Wi-Fi AP with dynamic updating SSID broadcast on connection attempt, MAC logging for connection attempts, random AP MAC broadcast and chanel broadcast number for limiting a single point of attack.

> If you have a RPI and want to broadcast Wi-Fi to totarget Wi-Fi Neirbour hacking and haggle the hacker then this might be for you.
>
> Loga ALL connection attempts to a bogus wifi network and choose between several scripts to let the hacker know that you are on to them. log their Mac address and more...


Hammered this out quickly when next door deployed a script kiddie mobile phone app pineapple attack to target my Wi-Fi. they quickly found out that their device address (Mac address) was now in my hands.

TIP: hostapd was not intended for dynamic updating so keep the service restarts. 

see <a href="https://github.com/asylum119/my-scripts/blob/master/RPI%20Wi-Fi%20Honeypot/honeypot/script/hacker-challenge.sh">Hacker challenge script</a> for example of dynamic SSID updating. 

## Installation

> See Build.html
