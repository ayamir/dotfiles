#!/bin/bash

sh ~/.fehbg

arr=("xfce4-power-manager" "copyq" "fcitx5" "dunst" "xdman" "clipmenud" "qv2ray" "redshift-gtk" "mpd" "picom" "qbittorrent")

for value in ${arr[@]}
do
    isExist=`ps -ef | rg "$value" | rg -v rg | wc -l`
    if [ $isExist == 0 ]
    then
        exec "$value" &
    fi
done
