#!/bin/bash

sh ~/.fehbg
wmname compiz

arr=("goblocks" "xfce4-power-man" "copyq" "fcitx5" "dunst" "clipmenud" "mpd" "qv2ray" "solaar" "qbittorrent" "nutstore")

for value in ${arr[@]}; do
    if [[ ! $(pgrep ${value}) ]]; then
        exec "$value" &
    fi
done
