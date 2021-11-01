#!/bin/bash

arr=("xfce4-power-manager" "copyq" "fcitx5" "xfce4-notifyd" "nutstore" "mpd")

for value in ${arr[@]}; do
    if [[ ! $(pgrep ${value}) ]]; then
        exec "$value" &
    fi
done

if [[ ! $(pgrep xob) ]]; then
    exec "sxob"
fi
