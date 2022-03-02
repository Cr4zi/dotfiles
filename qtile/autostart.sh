#!/bin/sh
picom &
flameshot &
lxsession &
nm-applet &
dunst &
volumeicon &
/usr/bin/emacs --daemon &
setxkbmap -option grp:alt_shift_toggle "us,il"
xrandr --output DP-4 --primary --right-of HDMI-0
feh --bg-scale ~/Pictures/Backgrounds/02.jpg
