#!/bin/bash
# Print commands before executing and exit when any command fails
set -xe


install_config(){
  local bleachbit_hash=$(cat /dev/urandom | tr -dc "a-zA-Z0-9" | fold -w 128 | head -n 1)

  # Configure our config files
  sed -i "s/^hashsalt =/hashsalt = ${bleachbit_hash}/g" config/bleachbit/bleachbit.ini
  sed -i "s/USERNAME/$USER/g" config/bleachbit/bleachbit.ini
  sed -i "s/USERNAME/$USER/g" config/gtk-3.0/bookmarks
  sed -i "s/USERNAME/$USER/g" config/pcmanfm-qt/lxqt/settings.conf
  sed -i "s/USERNAME/$USER/g" config/qterminal.org/qterminal.ini

  # Copy our config for quick easy setup
  sudo rm -rf ~/.config
  cp -R config ~/.config
  sudo rm -rf ~/.icons
  cp -R icons ~/.icons
  cp gtkrc-2.0 ~/.gtkrc-2.0

  # Add our custom SDDM theme
  curl -o sddm-transcendence.zip https://codeload.github.com/daechir/sddm-transcendence/zip/v1
  unzip sddm-transcendence.zip
  mv sddm-transcendence-1 Transcendence
  sudo cp -R Transcendence /usr/share/sddm/themes/
  sudo chmod -R 755 /usr/share/sddm/themes/Transcendence/
  echo -e "[Theme]\nCurrent=Transcendence" | sudo tee -a /etc/sddm.conf > /dev/null

  return 0
}


install_config

exit 0

