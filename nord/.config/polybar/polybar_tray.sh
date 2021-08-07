#! /bin/bash

pgrep -a polybar | grep polybar-tray | awk '{print $1}' | xargs kill ||
    polybar --config=$HOME/.config/polybar/polybar-tray.config main
