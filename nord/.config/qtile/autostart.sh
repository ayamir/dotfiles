#!/bin/bash

sh ~/.fehbg
wmname compiz

arr=("goblocks" "xfce4-power-manager" "copyq" "fcitx5" "xfce4-notifyd" "solaar" "nutstore" "qbittorrent" "mpd")

for value in ${arr[@]}; do
    if [[ ! $(pgrep ${value}) ]]; then
        exec "$value" &
    fi
done

if [[ ! $(pgrep xob) ]]; then
    exec "sxob"
fi
