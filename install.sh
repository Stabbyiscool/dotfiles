#!/bin/bash

echo "Ok instfall!"

sudo pacman -S --needed - < packagesneeded.txt
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
yay -S wayfreeze activate-linux swaysome swaylock-effects way-audio-idle-inhibit-git

echo "
--------------------
ok thnak for install
--------------------"