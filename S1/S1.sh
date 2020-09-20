#!/bin/bash
# Print commands before executing and exit when any command fails
set -xe


install_setup() {
  # First enable the firewall
  sudo ufw enable
  sudo systemctl enable ufw.service
  sudo systemctl start ufw.service
  sudo ufw logging off

  # Then update apt database
  sudo apt update -y

  # Next remove some default programs
  sudo apt remove --purge 2048-qt avahi-daemon avahi-utils bluedevil bluez bluez-cups bluez-obexd cups-browsed geoclue-2.0 mobile-broadband-provider-info modemmanager noblenote qlipper qtpass quassel samba-libs snapd transmission-qt trojita usb-modeswitch usb-modeswitch-data vim whoopsie -y

  # Finally add our custom programs and upgrade the system
  sudo apt install bleachbit gufw -y
  sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y
}


cleanup_defaults() {
  # Cleanup Lubuntu defaults
  local cleanup_paths=(
    "/etc/modprobe.d/"
    "/etc/modules-load.d/"
    "/etc/NetworkManager/conf.d/"
    "/etc/sysctl.d/"
    "/usr/lib/modprobe.d/"
    "/usr/lib/modules-load.d/"
    "/usr/lib/NetworkManager/conf.d/"
    "/usr/lib/sysctl.d/"
  )

  for path in "${cleanup_paths[@]}"
  do
    sudo rm -rf "${path}"
    sudo mkdir "${path}"
  done
}


toggle_systemctl() {
  # Disable some unused services, sockets and targets
  local systemctl=(
    "accounts-daemon.service"
    "avahi-daemon.service"
    "avahi-dnsconfd.service"
    "bluetooth.service"
    "cups-browsed.service"
    "dundee.service"
    "ModemManager.service"
    "ofono.service"
    "snapd.service"
    "systemd-coredump@.service"
    "systemd-hibernate-resume@.service"
    "systemd-hibernate.service"
    "systemd-hybrid-sleep.service"
    "systemd-suspend-then-hibernate.service"
    "systemd-suspend.service"
    "whoopsie.service"
    "avahi-daemon.socket"
    "snapd.socket"
    "systemd-coredump.socket"
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

  for ctl in "${systemctl[@]}"
  do
    local ctlactive=$(systemctl status "${ctl}" | grep -i "active: active")
    local ctlexist=$(ls -la /usr/lib/systemd/system | grep -i "${ctl}")

    if [[ -n "${ctlactive}" ]]; then
      sudo systemctl stop "${ctl}" 2> /dev/null
    fi

    if [[ -n "${ctlexist}" ]]; then
      sudo systemctl disable "${ctl}"
    fi

    sudo systemctl mask "${ctl}"
  done
}


misc_fixes() {
  # Adjust journal file size
  sudo sed -i "s/^#SystemMaxUse=/SystemMaxUse=50M/g" /etc/systemd/journald.conf

  # Fix systemd shutdown hanging issue
  sudo sed -i "s/^#DefaultTimeoutStopSec=90s/DefaultTimeoutStopSec=10s/g"  /etc/systemd/system.conf
  sudo sed -i "s/^#DefaultTimeoutStartSec=90s/DefaultTimeoutStartSec=10s/g"  /etc/systemd/system.conf
}


harden_parts() {
  # Harden coredumps
  echo -e "[Coredump]\nStorage=none\nProcessSizeMax=0" | sudo tee -a  /etc/systemd/coredump.conf > /dev/null
  sudo sed -i "s/^# End of file/* hard core 0/g" /etc/security/limits.conf
  echo -e "\n# End of file" | sudo tee -a  /etc/security/limits.conf > /dev/null

  # Harden file permissions (1/2)
  echo -e "\n# Harden file permissions\numask 077" | sudo tee -a /etc/profile > /dev/null

  # Harden hosts
  sudo sed -i "1,3!d" /etc/hosts

  ## Harden history file creation
  # Disable defaults
  sed -i "s/^HISTCONTROL=ignoreboth/#HISTCONTROL=ignoreboth/g" ~/.bashrc
  sed -i "s/^shopt -s histappend/#shopt -s histappend/g" ~/.bashrc
  sed -i "s/^HISTSIZE=1000/#HISTSIZE=1000/g" ~/.bashrc
  sed -i "s/^HISTFILESIZE=2000/#HISTFILESIZE=2000/g" ~/.bashrc
  # Add our new values
  echo -e "\n# Disable .bash_history\nHISTFILE=/dev/null\nHISTFILESIZE=0\nHISTSIZE=0\nexport HISTFILE HISTFILESIZE HISTSIZE" | tee -a ~/.bashrc > /dev/null
  echo -e "\n# Disable .bash_history\nHISTFILE=/dev/null\nHISTFILESIZE=0\nHISTSIZE=0\nexport HISTFILE HISTFILESIZE HISTSIZE" | sudo tee -a /etc/profile > /dev/null
  echo -e "\n# Disable .lesshst\nLESSHISTFILE=/dev/null\nLESSHISTSIZE=0\nexport LESSHISTFILE LESSHISTSIZE" | tee -a ~/.bashrc > /dev/null
  echo -e "\n# Disable .lesshst\nLESSHISTFILE=/dev/null\nLESSHISTSIZE=0\nexport LESSHISTFILE LESSHISTSIZE" | sudo tee -a /etc/profile > /dev/null

  # Harden kernel startup parameters
  sudo sed -i 's/^GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="apparmor=1 security=apparmor spectre_v2=on spec_store_bypass_disable=on tsx=off tsx_async_abort=full,nosmt mds=full,nosmt l1tf=full,force nosmt=force kvm.nx_huge_pages=force random.trust_cpu=off intel_iommu=on amd_iommu=on efi=disable_early_pci_dma slab_nomerge slub_debug=FZ init_on_alloc=1 init_on_free=1 mce=0 pti=on vsyscall=none page_alloc.shuffle=1 lockdown=confidentiality module.sig_enforce=1 extra_latent_entropy oops=panic nowatchdog ipv6.disable=1"/g' /etc/default/grub
  echo -e '#!/bin/bash\n\n# Force our kernel parameters on each boot\nsudo sysctl -p\n\nexit 0' | sudo tee -a /etc/rc.local > /dev/null
  sudo chmod 755 /etc/rc.local
  sudo chmod +x  /etc/rc.local

  # Harden less
  echo -e "\n# Enable LESSSECURE mode\nexport LESSSECURE=1" | tee -a ~/.bashrc > /dev/null
  echo -e "\n# Enable LESSSECURE mode\nexport LESSSECURE=1" | sudo tee -a /etc/profile > /dev/null
  echo -e "\n# Unset LESSOPEN and LESSCLOSE\nunset LESSOPEN LESSCLOSE" | tee -a ~/.bashrc > /dev/null
  echo -e "\n# Unset LESSOPEN and LESSCLOSE\nunset LESSOPEN LESSCLOSE" | sudo tee -a /etc/profile > /dev/null

  # Harden modules
  # Kernel level
  sudo cp etc/modules/00_blacklisted.conf /etc/modprobe.d/

  # Harden NetworkManager
  sudo cp etc/NetworkManager/dispatcher.d/00_control_multicast.sh /etc/NetworkManager/dispatcher.d/
  sudo chmod +x /etc/NetworkManager/dispatcher.d/00_control_multicast.sh

  # Harden root account
  sudo sed -i "15 s/^# auth/auth/g" /etc/pam.d/su
  sudo passwd -l root

  # Harden sudoedit
  echo "EDITOR=rnano" | sudo tee -a /etc/environment > /dev/null

  # Harden sysctl
  sudo cp etc/00_xenos_hardening.conf /etc/sysctl.d/
  sudo cp etc/00_xenos_hardening.conf /etc/sysctl.conf

  # Harden Systemd resolved settings
  sudo sed -i "1,12!d" /etc/systemd/resolved.conf
  echo -e "\n[Resolve]\n#DNS=\nFallbackDNS=\nDomains=\nDNSSEC=yes\nDNSOverTLS=no\nMulticastDNS=no\nLLMNR=no\nCache=yes\nDNSStubListener=yes\nReadEtcHosts=yes\nResolveUnicastSingleLabel=no" | sudo tee -a  /etc/systemd/resolved.conf > /dev/null

  # Harden Systemd sleep
  sudo sed -i "s/^#AllowSuspend=yes/AllowSuspend=no/g" /etc/systemd/sleep.conf
  sudo sed -i "s/^#AllowHibernation=yes/AllowHibernation=no/g" /etc/systemd/sleep.conf
  sudo sed -i "s/^#AllowSuspendThenHibernate=yes/AllowSuspendThenHibernate=no/g" /etc/systemd/sleep.conf
  sudo sed -i "s/^#AllowHybridSleep=yes/AllowHybridSleep=no/g" /etc/systemd/sleep.conf
  sudo sed -i "s/^OnlyShowIn=.*/NoDisplay=true;/g" /usr/share/applications/lxqt-hibernate.desktop
  sudo sed -i "s/^OnlyShowIn=.*/NoDisplay=true;/g" /usr/share/applications/lxqt-suspend.desktop
  sudo sed -i "s/^OnlyShowIn=.*/NoDisplay=true;/g" /usr/share/applications/lxqt-leave.desktop

  # Regenerate grub
  sudo update-grub

  # Harden file permissions (2/2)
  sudo chmod -R 700 /boot /etc/ufw /etc/NetworkManager /usr/lib/NetworkManager

  # Harden mount options
  sudo sed -i "s/defaults/defaults,noatime/g" /etc/fstab
  echo -e "\n/var /var ext4 defaults,bind,noatime,nosuid,nodev 0 0" | sudo tee -a  /etc/fstab > /dev/null
  echo "/home /home ext4 defaults,bind,noatime,nosuid,nodev,noexec 0 0" | sudo tee -a  /etc/fstab > /dev/null
  echo "tmpfs /tmp tmpfs defaults,noatime,nosuid,nodev,noexec 0 0" | sudo tee -a  /etc/fstab > /dev/null
  echo "tmpfs /dev/shm tmpfs defaults,noatime,nosuid,nodev,noexec 0 0" | sudo tee -a  /etc/fstab > /dev/null
  sudo mkdir /etc/systemd/system/systemd-logind.service.d/
  echo -e "[Service]\nSupplementaryGroups=sudo" | sudo tee -a  /etc/systemd/system/systemd-logind.service.d/00_hide_pid.conf  > /dev/null
  sudo chmod -R 644 /etc/systemd/system/systemd-logind.service.d/
  echo "proc /proc proc noatime,nosuid,nodev,noexec,hidepid=2,gid=sudo 0 0" | sudo tee -a  /etc/fstab > /dev/null
}


install_setup
cleanup_defaults
toggle_systemctl
misc_fixes
harden_parts

