#!/bin/bash

echo "Ok instfall!"

sudo pacman -S --noconfirm --needed - < packagesneeded.txt
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
yay -S --noconfirm wayfreeze activate-linux swaysome swaylock-effects way-audio-idle-inhibit-git
sudo cat <<'EOF' > "/etc/ly/config.ini"
hide_borders = true
EOF
echo "
--------------------
ok thnak for install
--------------------"
