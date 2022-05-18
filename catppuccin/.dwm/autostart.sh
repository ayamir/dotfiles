#!/bin/bash

start() {
	if ! pgrep -f $1; then
		exec $@ &
	fi
}

# monitor layout
randr

# wallpaper
nitrogen --restore

# restore brightness config
sudo chmod o+w /sys/class/backlight/amdgpu_bl0/brightness
light -I

# power manager
start xfce4-power-manager

# clipboard manager
start copyq

# notification center
start dunst

# system tray
start stalonetray

# compositor
start picom --experimental-backends --config $HOME/.config/picom/picom.conf

# auth
start /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1

# music notification
start snotify

# volume visual bar
start sxob

# load X colors
start xrdb "$HOME/.Xresources"

# start desktop apps
if [[ ! $(pgrep -f "fcitx5") ]]; then
	dex --autostart --environment awesome
fi
