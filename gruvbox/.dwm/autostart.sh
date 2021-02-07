#!/bin/bash

sh ~/.fehbg

arr=("/usr/lib/geoclue-2.0/demos/agent" "picom" "~/.dwm-bar/dwm_bar.sh" "xfce4-power-manager" "copyq" "redshift-gtk" "fcitx5" "nutstore" "dunst" "xdman" "clipmenud" "qv2ray")

for value in ${arr[@]}
do
    isExist=`ps -ef | grep "$value" | wc -l`
    if [ $isExist = 1 ] || [ $isExist = 0 ]
    then
        if [[ $value = "picom" ]]
        then
            exec `"$value" -b`
        else
            exec "$value" &
        fi
    fi
done
