#!/bin/bash
# This is a tinified version of xenos-control-dns.sh aimed at Lubuntu 20.04* LTS.
# It's intention is to ensure that certain networking features remain off.
#
# Author: Daechir
# Author URL: https://github.com/daechir
# Modified Date: 02/20/21
# Version: v1c


initialize(){
  #
  ## Device variable prep
  #
  # active_device_string: a string of device data used for manipulation
  #                       by default greps all connected devices then filters out special cases
  #                       eg "disconnected" often refers to wireless p2p devices
  #                          "connected (externally)" often refers to tap/tun devices
  # active_device_name: eg en* (ethernet) or wl* (wifi)
  # active_device_connection_name: eg the name of the connection ("Wired connection 1" "Wifi actually sucks")
  #
  active_device_string=$(nmcli device | grep -i "connected" | grep -v -i "disconnected\|connected (externally)")
  active_device_name=$(echo "${active_device_string}" | awk '{print $1}' | sed "s/^[ \t]*//;s/[ \t]*$//" | sed "/^$/d")
  active_device_connection_name=$(echo "${active_device_string}" | awk '{$1=$2=$3=""; print $0}' | sed "s/^[ \t]*//;s/[ \t]*$//" | sed "/^$/d")

  return 0
}

setup_connectivity(){
  local xenos_device=$1
  local xenos_connection=$2

  ip link set dev "${xenos_device}" allmulticast off
  ip link set dev "${xenos_device}" multicast off

  if [[ -n "${xenos_connection}" ]]; then
    if [[ "${xenos_device}" == wl* ]]; then
      nmcli connection mod "${xenos_connection}" 802-11-wireless.powersave 2
    fi

    nmcli connection mod "${xenos_connection}" connection.llmnr 0
    nmcli connection mod "${xenos_connection}" connection.mdns 0
  fi

  resolvectl llmnr "${xenos_device}" 0
  resolvectl mdns "${xenos_device}" 0

  return 0
}


## Initialize script
initialize

if [[ $1 == wl* || $1 == en* ]]; then
  case $2 in
    up)
      setup_connectivity "${active_device_name}" "${active_device_connection_name}"
      ;;
  esac
fi

exit 0

