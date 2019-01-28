# RPI Wi-Fi Honeypot

## Introduction

> RPI Fake Wi-Fi AP with dynamic updating SSID broadcast on connection attempt, MAC logging for connection attempts, random AP MAC broadcast and chanel broadcast number for limiting a single attack vector when broadcasting the hacker challeng SSID.

Hammered this out quickly when next door deployed a pineapple attack, maybe someone else can improve.

TIP: hostapd was not intended for dynamic updating so keep the service restarts. 

see <a href="https://github.com/asylum119/my-scripts/blob/master/RPI%20Wi-Fi%20Honeypot/honeypot/script/hacker-challenge.sh">Hacker challenge script</a> for example of dynamic SSID updating. 

## Installation

> See Build.html
