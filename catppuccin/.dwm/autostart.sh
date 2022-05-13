#!/bin/bash

start() {
	if ! pgrep -f $1; then
		$@ &
	fi
}

arr=("xfce4-power-manager" "copyq" "dunst" "mpDris2" "snotify")

for value in ${arr[@]}; do
	start $value
done

randr
nitrogen --restore
wmname compiz
sudo chmod o+w /sys/class/backlight/amdgpu_bl0/brightness
light -I

# compositor
start picom --experimental-backends --config $HOME/.config/picom/picom.conf

# auth
start /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1

# load X colors
start xrdb "$HOME/.Xresources"

if [[ ! $(pgrep -f "fcitx5") ]]; then
	dex --autostart --environment awesome
fi

if [[ ! $(pgrep -f "xob") ]]; then
	exec sxob
fi
