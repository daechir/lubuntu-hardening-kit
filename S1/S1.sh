#!/bin/bash
# Print commands before executing and exit when any command fails
set -xe


initialize(){
  superlite=""

  return 0
}

install_setup(){
  # Setup the firewall
  sudo ufw enable
  sudo systemctl enable ufw.service
  sudo systemctl start ufw.service
  sudo ufw default deny incoming
  sudo ufw default deny forward
  sudo ufw logging off

  # Update apt database
  sudo apt update

  ## Remove some default programs
  local core_purge="2048-qt apport apport-symptoms avahi-daemon avahi-utils bluedevil bluez bluez-cups bluez-obexd colord compton cups-browsed fcitx firefox ftp geoclue-2.0 irqbalance java-common kerneloops mobile-broadband-provider-info modemmanager noblenote partitionmanager picom plasma-discover popularity-contest qlipper qps qtpass quassel samba-libs skanlite snapd spice-vdagent tcpdump telnet transmission-qt trojita ubuntu-report unattended-upgrades usb-creator-kde usb-modeswitch usb-modeswitch-data vim vim-common whoopsie"

  if [[ -n "${superlite}" ]]; then
    core_purge="${core_purge} lxqt-archiver cups htop k3b kcalc libreoffice muon screengrab scrot vlc"
  fi

  sudo apt remove --purge $core_purge -y

  # Cleanup unused packages and or dependencies
  sudo apt autoremove -y

  ## Add our custom programs and upgrade the system
  local core_pack_1="apt-transport-https curl bleachbit gnupg gufw"

  if [[ -z "${superlite}" ]]; then
    core_pack_1="${core_pack_1} simple-scan"
  fi

  # Install core_pack_1
  sudo apt install $core_pack_1 -y

  # Brave
  sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee -a /etc/apt/sources.list.d/brave-browser-release.list > /dev/null
  local core_pack_2="brave-browser"

  # Canon printer drivers
  local usecanon=""

  if [[ -z "${superlite}" && -n "${usecanon}" ]]; then
    sudo add-apt-repository ppa:thierry-f/fork-michael-gruz -y
    core_pack_2="${core_pack_2} cnijfilter2"
  fi

  # Libreoffice-fresh
  if [[ -z "${superlite}" ]]; then
  	sudo add-apt-repository ppa:libreoffice/ppa -y
  fi

  # Install core_pack_2
  sudo apt update

  sudo apt install $core_pack_2 -y

  # Force the use of the newest mainline kernel
  curl -o ubuntu-mainline-kernel.sh https://raw.githubusercontent.com/pimlie/ubuntu-mainline-kernel.sh/master/ubuntu-mainline-kernel.sh
  sudo mv ubuntu-mainline-kernel.sh /usr/bin/
  sudo chmod 700 /usr/bin/ubuntu-mainline-kernel.sh
  sudo ubuntu-mainline-kernel.sh -i --yes

  # Upgrade the rest of the system
  sudo apt full-upgrade -y

  # And once again cleanup unused packages and or dependencies
  sudo apt autoremove -y && sudo apt autoclean && sudo apt clean

  return 0
}

toggle_systemctl(){
  # Disable some unused services, sockets and targets
  local systemctl=(
    "accounts-daemon.service"
    "alsa-restore.service"
    "alsa-state.service"
    "apport-autoreport.service"
    "apport-forward@.service"
    "apport.service"
    "avahi-daemon.service"
    "avahi-dnsconfd.service"
    "bluetooth.service"
    "colord.service"
    "cups-browsed.service"
    "dundee.service"
    "grub-initrd-fallback.service"
    "irqbalance.service"
    "kerneloops.service"
    "ModemManager.service"
    "networkd-dispatcher.service"
    "ofono.service"
    "rc-local.service"
    "rsync.service"
    "rsyslog.service"
    "rtkit-daemon.service"
    "snapd.service"
    "snapd.seeded.service"
    "spice-vdagent.service"
    "spice-vdagentd.service"
    "systemd-coredump@.service"
    "systemd-hibernate-resume@.service"
    "systemd-hibernate.service"
    "systemd-hybrid-sleep.service"
    "systemd-networkd.service"
    "systemd-networkd-wait-online.service"
    "systemd-network-generator.service"
    "systemd-rfkill.service"
    "systemd-suspend-then-hibernate.service"
    "systemd-suspend.service"
    "systemd-timedated.service"
    "systemd-timesyncd.service"
    "systemd-time-wait-sync.service"
    "unattended-upgrades.service"
    "whoopsie.service"
    "apport-forward.socket"
    "avahi-daemon.socket"
    "snapd.socket"
    "spice-vdagentd.socket"
    "syslog.socket"
    "systemd-coredump.socket"
    "systemd-networkd.socket"
    "systemd-rfkill.socket"
    "bluetooth.target"
    "hibernate.target"
    "hybrid-sleep.target"
    "remote-cryptsetup.target"
    "remote-fs-pre.target"
    "remote-fs.target"
    "sleep.target"
    "suspend-then-hibernate.target"
    "suspend.target"
  )

  if [[ -n "${superlite}" ]]; then
    systemctl="${systemctl[@]} cups.service cups.socket"
  fi

  for ctl in "${systemctl[@]}"
  do
    sudo systemctl mask "${ctl}"
  done

  return 0
}

misc_fixes(){
  # Fix apparmor boot time hanging issue
  sudo sed -i "s/^#write-cache/write-cache/g" /etc/apparmor/parser.conf

  # Fix NetworkManager mac address randomization race condition
  sudo sed -i "d" /etc/NetworkManager/NetworkManager.conf
  echo -e "# Configuration file for NetworkManager.\n# See \"man 5 NetworkManager.conf\" for details.\n\n[device]\nwifi.scan-rand-mac-address=no" | sudo tee -a /etc/NetworkManager/NetworkManager.conf > /dev/null

  return 0
}

harden_systemd_parts(){
  # Harden /etc/systemd/coredump.conf
  echo -e "[Coredump]\nStorage=none\nProcessSizeMax=0" | sudo tee -a /etc/systemd/coredump.conf > /dev/null

  # Harden /etc/systemd/journald.conf
  sudo sed -i "s/^#Storage=.*/Storage=persistent/g" /etc/systemd/journald.conf
  sudo sed -i "s/^#Compress=.*/Compress=yes/g" /etc/systemd/journald.conf
  sudo sed -i "s/^#SystemMaxUse=.*/SystemMaxUse=50M/g" /etc/systemd/journald.conf
  sudo sed -i "s/^#ForwardToSyslog=.*/ForwardToSyslog=yes/g" /etc/systemd/journald.conf

  # Harden /etc/systemd/resolved.conf
  sudo cp etc/resolved.conf /etc/systemd

  # Harden /etc/systemd/system.conf
  sudo sed -i "s/^#DumpCore=.*/DumpCore=no/g" /etc/systemd/system.conf
  sudo sed -i "s/^#CrashShell=.*/CrashShell=no/g" /etc/systemd/system.conf
  sudo sed -i "s/^#SystemCallArchitectures=.*/SystemCallArchitectures=native/g" /etc/systemd/system.conf
  sudo sed -i "s/^#DefaultTimeoutStartSec=.*/DefaultTimeoutStartSec=10s/g"  /etc/systemd/system.conf
  sudo sed -i "s/^#DefaultTimeoutStopSec=.*/DefaultTimeoutStopSec=10s/g"  /etc/systemd/system.conf
  sudo sed -i "s/^#DefaultLimitCORE=.*/DefaultLimitCORE=0/g" /etc/systemd/system.conf

  # Harden /etc/systemd/sleep.conf
  sudo sed -i "s/^#AllowSuspend=.*/AllowSuspend=no/g" /etc/systemd/sleep.conf
  sudo sed -i "s/^#AllowHibernation=.*/AllowHibernation=no/g" /etc/systemd/sleep.conf
  sudo sed -i "s/^#AllowSuspendThenHibernate=.*/AllowSuspendThenHibernate=no/g" /etc/systemd/sleep.conf
  sudo sed -i "s/^#AllowHybridSleep=.*/AllowHybridSleep=no/g" /etc/systemd/sleep.conf

  # Harden services at /etc/systemd/system/
  sudo cp -R usr/lib/systemd/system/ /etc/systemd/

  if [[ -z "${superlite}" ]]; then
    sudo cp usr/lib/systemd/system-optional/cups.service /etc/systemd/system/
  fi

  return 0
}

harden_other_parts(){
  # Deprecate /etc/environment
  sudo sed -i "d" /etc/environment

  # Harden apt
  echo -e "# Enable apt sandboxing.\nAPT::Sandbox::Seccomp \"true\";" | sudo tee -a /etc/apt/apt.conf.d/40sandbox > /dev/null

  # Harden consoles and ttys
  echo -e "\n+:(wheel):LOCAL\n-:ALL:ALL" | sudo tee -a /etc/security/access.conf > /dev/null
  sudo touch /etc/securetty
  echo -e "# File which lists terminals from which root can log in.\n# See securetty(5) for details." | sudo tee -a /etc/securetty > /dev/null

  # Harden hosts
  sudo sed -i "1,3!d" /etc/hosts

  ## Harden kernel startup parameters
  local is_intel_cpu=$(lscpu | grep -i "intel(r)" 2> /dev/null || echo "")
  # Begin grub_cmdline_line generation
  # Core security features
  local grub_cmdline_linux="apparmor=1 lsm=lockdown,yama,apparmor"
  # CPU mitigations
  grub_cmdline_linux="${grub_cmdline_linux} spectre_v2=on"
  grub_cmdline_linux="${grub_cmdline_linux} spec_store_bypass_disable=on"
  grub_cmdline_linux="${grub_cmdline_linux} tsx=off tsx_async_abort=full,nosmt"
  grub_cmdline_linux="${grub_cmdline_linux} mds=full,nosmt"
  grub_cmdline_linux="${grub_cmdline_linux} l1tf=full,force"
  grub_cmdline_linux="${grub_cmdline_linux} nosmt=force"
  grub_cmdline_linux="${grub_cmdline_linux} kvm.nx_huge_pages=force"
  # Distrust embedded CPU entropy
  grub_cmdline_linux="${grub_cmdline_linux} random.trust_cpu=off"
  # DMA hardening and misc fixes
  if [[ -n "${is_intel_cpu}" ]]; then
    grub_cmdline_linux="${grub_cmdline_linux} intel_iommu=on"
  else
    grub_cmdline_linux="${grub_cmdline_linux} amd_iommu=on"
  fi
  grub_cmdline_linux="${grub_cmdline_linux} efi=disable_early_pci_dma"
  # Kernel hardening
  grub_cmdline_linux="${grub_cmdline_linux} init_on_alloc=1 init_on_free=1"
  grub_cmdline_linux="${grub_cmdline_linux} mce=0"
  grub_cmdline_linux="${grub_cmdline_linux} page_alloc.shuffle=1"
  grub_cmdline_linux="${grub_cmdline_linux} pti=on"
  grub_cmdline_linux="${grub_cmdline_linux} randomize_kstack_offset=1"
  grub_cmdline_linux="${grub_cmdline_linux} slab_nomerge"
  grub_cmdline_linux="${grub_cmdline_linux} slub_debug=FZ"
  grub_cmdline_linux="${grub_cmdline_linux} vsyscall=none"
  # Custom additions
  grub_cmdline_linux="${grub_cmdline_linux} debugfs=off"
  grub_cmdline_linux="${grub_cmdline_linux} extra_latent_entropy"
  grub_cmdline_linux="${grub_cmdline_linux} ipv6.disable=1"
  grub_cmdline_linux="${grub_cmdline_linux} lockdown=confidentiality"
  grub_cmdline_linux="${grub_cmdline_linux} module.sig_enforce=1"
  grub_cmdline_linux="${grub_cmdline_linux} nowatchdog"
  grub_cmdline_linux="${grub_cmdline_linux} nohibernate"
  grub_cmdline_linux="${grub_cmdline_linux} oops=panic"
  grub_cmdline_linux="${grub_cmdline_linux} systemd.dump_core=0"
  sudo sed -i "s/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"${grub_cmdline_linux}\"/g" /etc/default/grub

  # Harden limits.conf
  sudo sed -i "s/^# End of file/* hard core 0/g" /etc/security/limits.conf
  echo -e "* hard maxsyslogins 1\n\n# End of file" | sudo tee -a  /etc/security/limits.conf > /dev/null

  ## Harden modules
  # Early boot (Kernel init)
  for modprobe in etc/modprobe.d/*
  do
    sudo cp "${modprobe}" /etc/modprobe.d/
  done

  ## Harden pam.d
  # SU elevation, even though SU will be disabled by locking root lets restrict it anyways
  sudo sed -i "15 s/^# auth/auth/g" /etc/pam.d/su
  # Lastly lock root account
  sudo passwd -l root

  # Harden profile
  sudo cp etc/profile /etc/

  # Harden sysctl
  sudo cp etc/00_xenos_hardening.conf /etc/sysctl.d/
  sudo cp etc/00_xenos_hardening.conf /etc/sysctl.conf

  # Harden mount options
  sudo sed -i "s/defaults/defaults,noatime/g" /etc/fstab
  echo -e "\n/var /var ext4 defaults,bind,noatime,nosuid,nodev 0 0" | sudo tee -a  /etc/fstab > /dev/null
  echo "/home /home ext4 defaults,bind,noatime,nosuid,nodev,noexec 0 0" | sudo tee -a  /etc/fstab > /dev/null
  echo "tmpfs /tmp tmpfs defaults,noatime,nosuid,nodev,noexec 0 0" | sudo tee -a  /etc/fstab > /dev/null
  echo "tmpfs /dev/shm tmpfs defaults,noatime,nosuid,nodev,noexec 0 0" | sudo tee -a  /etc/fstab > /dev/null
  sudo mkdir /etc/systemd/system/systemd-logind.service.d/
  echo -e "[Service]\nSupplementaryGroups=sudo" | sudo tee -a  /etc/systemd/system/systemd-logind.service.d/00_hide_pid.conf  > /dev/null
  echo "proc /proc proc noatime,nosuid,nodev,noexec,hidepid=2,gid=sudo 0 0" | sudo tee -a  /etc/fstab > /dev/null

  # Harden file permissions
  sudo chmod -R 700 /boot /etc/ufw /etc/NetworkManager /usr/lib/NetworkManager
  sudo find /etc/systemd/system/ -type f -exec chmod 644 {} \;

  # Regenerate grub
  sudo update-grub

  # Hide lxqt items
  sudo sed -i "s/^OnlyShowIn=.*/NoDisplay=true;/g" /usr/share/applications/lxqt-hibernate.desktop
  sudo sed -i "s/^OnlyShowIn=.*/NoDisplay=true;/g" /usr/share/applications/lxqt-suspend.desktop
  sudo sed -i "s/^OnlyShowIn=.*/NoDisplay=true;/g" /usr/share/applications/lxqt-leave.desktop

  # Setup .bashrc
  sudo cp tilde/bashrc /etc/skel/.bashrc
  sudo cp /etc/skel/.bashrc ~

  # Setup systemd-resolved stub resolver
  sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

  # Setup 00_control_multicast.sh
  sudo cp etc/NetworkManager/dispatcher.d/00_control_multicast.sh /etc/NetworkManager/dispatcher.d/
  sudo chmod 700 /etc/NetworkManager/dispatcher.d/00_control_multicast.sh
  sudo chattr +i /etc/NetworkManager/dispatcher.d/00_control_multicast.sh

  # Setup lubuntu-control-defaults
  sudo cp etc/systemd/system/lubuntu-control-defaults.service /etc/systemd/system/
  sudo cp usr/bin/lubuntu-control-defaults.sh /usr/bin/
  sudo chmod 700 /usr/bin/lubuntu-control-defaults.sh
  sudo chattr +i /usr/bin/lubuntu-control-defaults.sh
  sudo systemctl enable lubuntu-control-defaults.service

  return 0
}


initialize
install_setup
toggle_systemctl
misc_fixes
harden_systemd_parts
harden_other_parts

exit 0

