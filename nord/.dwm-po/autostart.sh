#!/bin/bash

sh ~/.fehbg
wmname compiz

arr=("xfce4-power-man" "copyq" "fcitx5" "dunst" "clipmenud" "qv2ray" "redshift-gtk" "mpd" "picom" "qbittorrent" "nutstore" "solaar")

for value in ${arr[@]}; do
  if [[ ! $(pgrep ${value}) ]]; then
    exec "$value" &
  fi
done
