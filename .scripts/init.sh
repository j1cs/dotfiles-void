#!/usr/bin/env sh
~/.screenlayout/home.sh;
sleep 1;
nitrogen --restore;
sleep 1;
picom -b;
sleep 1;
pkill -HUP spectrwm;
sleep 1;
~/.config/polybar/panel.sh;
