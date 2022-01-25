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
WSACTIVE="$(leftwm-state -q -t $LPATH/misc/workspaceid.liquid)"

# Items to display
LAYOUT="$(leftwm-state -q -n -w $WSACTIVE -s "{{workspace.layout}}")"
PREV=""
NEXT=""

# Rofi config
rofi_cmd="rofi -theme $LPATH/rasi/layout.rasi"
display="$PREV\n$NEXT"

# Main
chosen="$(echo -e "$display" | \
$rofi_cmd -p "$LAYOUT" -dmenu \
-theme-str 'window {location: '$LOCATION';}' \
-selected-row 1\
)"

# Use choosen 
case $chosen in
    $PREV)
        leftwm-command "PreviousLayout"
        ${0}
        ;;
    $NEXT)
        leftwm-command "NextLayout"
        ${0}
        ;;        
esac