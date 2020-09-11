#!/bin/bash
# This is a tinified version of xenos-control-dns-*.sh aimed at Lubuntu 20.04 LTS.
# It's intention is to ensure that certain networking features remain off.
#
# Author: Daechir
# Author URL: https://github.com/daechir
# Modified Date: 07/12/20
# Version: v1


# Variables
# Fetch only the active networking device name (EG: enp$, wl$ and etc)
active_device=$(ip -o link show | awk '{print $2,$9}' | grep "UP" | awk '{print $1}' | sed "s/://g")


force_settings(){
  local xenos_device=$1

  ip link set dev "${xenos_device}" allmulticast off
  ip link set dev "${xenos_device}" multicast off
  resolvectl llmnr "${xenos_device}" 0
  resolvectl mdns "${xenos_device}" 0
}


if [[ $1 == wlo* || $1 == enp* ]]; then
  case $2 in
    up)
      force_settings "$active_device"
      ;;
  esac
fi

