#!/bin/bash
# This script serves to control several annoyances that are shipped preconfigured in Lubuntu.
#
# Author: Daechir
# Author URL: https://github.com/daechir
# Modified Date: 02/20/21
# Version: v1a


control_defaults(){
  local files1=/etc/modprobe.d/*
  local files2=/etc/modules-load.d/*
  local files3=/etc/NetworkManager/conf.d/*
  local files4=/etc/sysctl.d/*
  local files5=/usr/lib/modprobe.d/*
  local files6=/usr/lib/modules-load.d/*
  local files7=/usr/lib/NetworkManager/conf.d/*
  local files8=/usr/lib/sysctl.d/*

  for file in $files1
  do
    local filegrep=$(grep -i "xenos" "${file}")

    if [[ -z "${filegrep}" ]]; then
      rm -f "${file}"
    fi
  done

  for file in $files2
  do
    rm -f "${file}"
  done

  for file in $files3
  do
    rm -f "${file}"
  done

  for file in $files4
  do
    if [[ "${file##*/}" != "00_xenos_hardening.conf" ]]; then
      rm -f "${file}"
    fi
  done

  for file in $files5
  do
    if [[ "${file##*/}" != "systemd.conf" ]]; then
      rm -f "${file}"
    fi
  done

  for file in $files6
  do
    rm -f "${file}"
  done

  for file in $files7
  do
    rm -f "${file}"
  done

  for file in $files8
  do
    rm -f "${file}"
  done

  return 0
}


control_defaults

exit 0

