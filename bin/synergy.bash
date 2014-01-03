#!/usr/bin/env bash

# If you are on ubuntu, put this program to "right top of screen (gears) > Startup Applications..."


err(){
  echo "ERROR : $1 !!!"
  exit 1
}

# get the eth used
ethname="$(ifconfig | grep eth | xargs | cut -d' ' -f1 | head -1)"
[[ -z "$ethname" ]] && err "No eth found"

#mask="$(ifconfig "$ethname")

myIp="$(ifconfig "$ethname" | grep "$inet addr:" | xargs | cut -d' ' -f2 | cut -d: -f2)"
mask="$(ifconfig "$ethname" | grep "$inet addr:" | xargs | cut -d' ' -f4 | cut -d: -f2)"

nbBits=0
case "$mask" in
  255.255.255.0) nbBits=24;;
  *) err "mask $mask not allowed";;
esac

network="$myIp/$nbBits"

echo "IP       : $myIp"
echo "mask     : $mask"
echo "network  : $network"

otherIp="$(nmap -sP "$network" -exclude "$myIp" 2>/dev/null |\
  egrep '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' |\
  sed 's/[^.0-9]//g' |\
  head -1)"

echo "found IP : $otherIp"

echo "Launching synergy"
synergyc --daemon --name "ubuntu_mick" --restart "$otherIp"

#__EOF__
