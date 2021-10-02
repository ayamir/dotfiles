#!/bin/bash

sh ~/.fehbg
wmname compiz

arr=("goblocks" "xfce4-power-man" "copyq" "fcitx5" "dunst" "solaar" "nutstore" "qbittorrent" "mpd")

for value in ${arr[@]}; do
    if [[ ! $(pgrep ${value}) ]]; then
        exec "$value" &
    fi
done
