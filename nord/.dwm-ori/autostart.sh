#!/bin/bash

sh ~/.fehbg

arr=("goblocks" "xfce4-power-manager" "copyq" "fcitx5" "dunst" "clipmenud" "mpd" "picom" "qv2ray" "solaar")

for value in ${arr[@]}
do
    isExist=`ps -ef | grep "$value" | grep -v grep | wc -l`
    if [ $isExist = 0 ]
    then
        exec "$value" &
    fi
done
