#!/bin/bash
# This is a tinified version of xenos-control-dns*.sh aimed at Lubuntu 20.04* LTS.
# It's intention is to ensure that certain networking features remain off.
#
# Author: Daechir
# Author URL: https://github.com/daechir
# Modified Date: 09/19/20
# Version: v1a


## Variables
# Hamdlers
active_device=$(ip -o link show | awk '{print $2,$9}' | grep -i "up" | awk '{print $1}' | sed "s/://g")

if [[ -n "${active_device}" ]]; then
  case "${active_device}" in
    wlo*)
      active_device_connection=$(nmcli connection show --active | grep -i "wifi" | awk '{print $1,$2,$3}')
      ;;
    enp*)
      active_device_connection=$(nmcli connection show --active | grep -i "ethernet" | awk '{print $1,$2,$3}')
      ;;
  esac
fi


setup_connectivity(){
  local xenos_device=$1
  local xenos_connection=$2

  ip link set dev "${xenos_device}" allmulticast off
  ip link set dev "${xenos_device}" multicast off

  if [[ -n "${xenos_connection}" ]]; then
    if [[ "${xenos_device}" == wlo* ]]; then
      nmcli connection mod "${xenos_connection}" 802-11-wireless.powersave 2
    fi

    nmcli connection mod "${xenos_connection}" connection.llmnr 0
    nmcli connection mod "${xenos_connection}" connection.mdns 0
  fi

  resolvectl llmnr "${xenos_device}" 0
  resolvectl mdns "${xenos_device}" 0
}


if [[ $1 == wlo* || $1 == enp* ]]; then
  case $2 in
    up)
      setup_connectivity "${active_device}" "${active_device_connection}"
      ;;
  esac
fi

