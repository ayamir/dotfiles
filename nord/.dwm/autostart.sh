#!/bin/bash

sh ~/.fehbg

arr=("dwmbar" "xfce4-power-manager" "copyq" "fcitx5" "dunst" "xdman" "clipmenud" "qv2ray" "redshift-gtk" "mpd" "picom")

for value in ${arr[@]}
do
    isExist=`ps -ef | grep "$value" | grep -v grep | wc -l`
    if [ $isExist = 0 ]
    then
        exec "$value" &
    fi
done
