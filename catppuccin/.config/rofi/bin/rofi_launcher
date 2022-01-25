#!/usr/bin/env bash

# SETTINGS ####################################################
# Possible positions:
# center
# north
# northeast
# east
# southeast
# south
# southwest
# west
# northwest
LOCATION="center"
###############################################################

LPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Rofi config
rofi_cmd="rofi -theme $LPATH/rasi/launcher.rasi"

# Main
$rofi_cmd -no-lazy-grab -show drun -modi drun \
-theme-str 'window {location: '$LOCATION';}' 
