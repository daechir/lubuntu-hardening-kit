#!/bin/bash
# This script serves to control several annoyances that are shipped preconfigured in Lubuntu 21.04*.
#
# Author: Daechir
# Author URL: https://github.com/daechir
# Modified Date: 06/13/21
# Version: v1b


control_folders(){
  local folder1=/etc/modprobe.d/*
  local folder2=/etc/modules-load.d/*
  local folder3=/etc/NetworkManager/conf.d/*
  local folder4=/etc/sysctl.d/*
  local folder5=/usr/lib/modprobe.d/*
  local folder6=/usr/lib/modules-load.d/*
  local folder7=/usr/lib/NetworkManager/conf.d/*
  local folder8=/usr/lib/sysctl.d/*

  for item in $folder1
  do
    if [[ -f "${item}" ]]; then
      local filegrep=$(grep -i "xenos" "${item}")

      if [[ -z "${filegrep}" ]]; then
        rm -f "${item}"
      fi
    fi

    if [[ -d "${item}" ]]; then
      rm -rf "${item}"
    fi
  done

  for item in $folder2
  do
    if [[ -f "${item}" ]]; then
      rm -f "${item}"
    fi

    if [[ -d "${item}" ]]; then
      rm -rf "${item}"
    fi
  done

  for item in $folder3
  do
    if [[ -f "${item}" ]]; then
      rm -f "${item}"
    fi

    if [[ -d "${item}" ]]; then
      rm -rf "${item}"
    fi
  done

  for item in $folder4
  do
    if [[ -f "${item}" ]]; then
      if [[ "${item##*/}" != "00_xenos_hardening.conf" ]]; then
        rm -f "${item}"
      fi
    fi

    if [[ -d "${item}" ]]; then
      rm -rf "${item}"
    fi
  done

  for item in $folder5
  do
    if [[ -f "${item}" ]]; then
      if [[ "${item##*/}" != "systemd.conf" ]]; then
        rm -f "${item}"
      fi
    fi

    if [[ -d "${item}" ]]; then
      rm -rf "${item}"
    fi
  done

  for item in $folder6
  do
    if [[ -f "${item}" ]]; then
      rm -f "${item}"
    fi

    if [[ -d "${item}" ]]; then
      rm -rf "${item}"
    fi
  done

  for item in $folder7
  do
    if [[ -f "${item}" ]]; then
      rm -f "${item}"
    fi

    if [[ -d "${item}" ]]; then
      rm -rf "${item}"
    fi
  done

  for item in $folder8
  do
    if [[ -f "${item}" ]]; then
      rm -f "${item}"
    fi

    if [[ -d "${item}" ]]; then
      rm -rf "${item}"
    fi
  done

  return 0
}

control_suid(){
  local suid_binaries=(
    "apt"
    "apt-get"
    "ar"
    "aria2c"
    "arp"
    "ash"
    "at"
    "atobm"
    "awk"
    "base32"
    "base64"
    "basenc"
    "bash"
    "bpftrace"
    "bridge"
    "bsd-write"
    "bundler"
    "busctl"
    "busybox"
    "byebug"
    "c89"
    "c99"
    "cancel"
    "capsh"
    "cat"
    "certbot"
    "chage"
    "check_by_ssh"
    "check_cups"
    "check_log"
    "check_memory"
    "check_raid"
    "check_ssl_cert"
    "check_statusfile"
    "chfn"
    "chmod"
    "chown"
    "chroot"
    "chsh"
    "cobc"
    "column"
    "comm"
    "composer"
    "cowsay"
    "cowthink"
    "cp"
    "cpan"
    "cpio"
    "cpulimit"
    "crash"
    "crontab"
    "csh"
    "csplit"
    "csvtool"
    "cupsfilter"
    "curl"
    "cut"
    "dash"
    "date"
    "dd"
    "dialog"
    "diff"
    "dig"
    "dmesg"
    "dmsetup"
    "dnf"
    "docker"
    "dpkg"
    "dvips"
    "easy_install"
    "eb"
    "ed"
    "emacs"
    "env"
    "eqn"
    "ex"
    "exiftool"
    "expand"
    "expect"
    "facter"
    "file"
    "find"
    "finger"
    "flock"
    "fmt"
    "fold"
    "ftp"
    "fusermount"
    "gawk"
    "gcc"
    "gdb"
    "gem"
    "genisoimage"
    "ghc"
    "ghci"
    "gimp"
    "git"
    "grep"
    "gtester"
    "gzip"
    "hd"
    "head"
    "hexdump"
    "highlight"
    "hping3"
    "iconv"
    "iftop"
    "install"
    "ionice"
    "ip"
    "irb"
    "jjs"
    "join"
    "journalctl"
    "jq"
    "jrunscript"
    "ksh"
    "ksshell"
    "latex"
    "ld.so"
    "ldconfig"
    "less"
    "logsave"
    "look"
    "ltrace"
    "lua"
    "lualatex"
    "luatex"
    "lwp-download"
    "lwp-request"
    "mail"
    "make"
    "man"
    "mawk"
    "mlocate"
    "more"
    "mount"
    "mount.nfs"
    "msgattrib"
    "msgcat"
    "msgconv"
    "msgfilter"
    "msgmerge"
    "msguniq"
    "mtr"
    "mv"
    "mysql"
    "nano"
    "nawk"
    "nc"
    "netfilter-persistent"
    "newgrp"
    "nice"
    "nl"
    "nmap"
    "node"
    "nohup"
    "npm"
    "nroff"
    "nsenter"
    "ntfs-3g"
    "octave"
    "od"
    "openssl"
    "openvpn"
    "openvt"
    "paste"
    "pdb"
    "pdflatex"
    "pdftex"
    "perl"
    "pg"
    "php"
    "pic"
    "pico"
    "ping"
    "ping6"
    "pip"
    "pkexec"
    "pkg"
    "pppd"
    "pr"
    "pry"
    "psad"
    "psql"
    "puppet"
    "python"
    "rake"
    "readelf"
    "red"
    "redcarpet"
    "restic"
    "rev"
    "rlogin"
    "rlwrap"
    "rpm"
    "rpmquery"
    "rsync"
    "ruby"
    "run-mailcap"
    "run-parts"
    "rview"
    "rvim"
    "scp"
    "screen"
    "script"
    "sed"
    "service"
    "setarch"
    "sftp"
    "sg"
    "sh"
    "shuf"
    "slsh"
    "smbclient"
    "snap"
    "socat"
    "soelim"
    "sort"
    "split"
    "sqlite3"
    "ss"
    "ssh"
    "ssh-keygen"
    "ssh-keyscan"
    "start-stop-daemon"
    "stdbuf"
    "strace"
    "strings"
    "su"
    "sysctl"
    "systemctl"
    "tac"
    "tail"
    "tar"
    "taskset"
    "tbl"
    "tclsh"
    "tcpdump"
    "tcsh"
    "tee"
    "telnet"
    "tex"
    "tftp"
    "time"
    "timeout"
    "tmux"
    "top"
    "traceroute6.iputils"
    "troff"
    "ul"
    "umount"
    "unexpand"
    "uniq"
    "unshare"
    "update-alternatives"
    "uudecode"
    "uuencode"
    "valgrind"
    "vi"
    "view"
    "vigr"
    "vim"
    "vimdiff"
    "vipw"
    "virsh"
    "wall"
    "watch"
    "wc"
    "wget"
    "whois"
    "wish"
    "write"
    "xargs"
    "xelatex"
    "xetex"
    "xmodmap"
    "xmore"
    "xxd"
    "xz"
    "yelp"
    "yum"
    "zip"
    "zsh"
    "zsoelim"
    "zypper"
  )

  local suid_binary_paths=()

  for binary in "${suid_binaries[@]}"
  do
    local suid_binary_path_1="/usr/bin/${binary}"
    local suid_binary_path_2="/usr/sbin/${binary}"

    if [[ -f "${suid_binary_path_1}" ]]; then
      suid_binary_paths=("${suid_binary_paths[@]}" "${suid_binary_path_1}")
    fi
    
    if [[ -f "${suid_binary_path_2}" ]]; then
      suid_binary_paths=("${suid_binary_paths[@]}" "${suid_binary_path_2}")
    fi
  done

  for binary_path in "${suid_binary_paths[@]}"
  do
    chmod -s "${binary_path}"
  done

  return 0
}


control_folders
control_suid

exit 0

