#!/bin/sh

# A modular status bar for dwm
# Joe Standring <git@joestandring.com>
# GNU GPLv3

# Dependencies: xorg-xsetroot

# Import functions with "$include /route/to/module"
# It is recommended that you place functions in the subdirectory ./bar-functions and use: . "$DIR/bar-functions/dwm_example.sh"

# Store the directory the script is running from
LOC=$(readlink -f "$0")
DIR=$(dirname "$LOC")

# Change the appearance of the module identifier. if this is set to "unicode", then symbols will be used as identifiers instead of text. E.g. [📪 0] instead of [MAIL 0].
# Requires a font with adequate unicode character support
export IDENTIFIER="unicode"

# Change the charachter(s) used to seperate modules. If two are used, they will be placed at the start and end.
export SEP1="["
export SEP2="]"

# Import the modules
. "$DIR/bar-functions/dwm_mpc.sh"
. "$DIR/bar-functions/dwm_spotify.sh"
. "$DIR/bar-functions/dwm_resources.sh"
. "$DIR/bar-functions/dwm_battery.sh"
. "$DIR/bar-functions/dwm_pulse.sh"
. "$DIR/bar-functions/dwm_date.sh"
. "$DIR/bar-functions/dwm_upt.sh"
. "$DIR/bar-functions/dwm_kernel.sh"

# Update dwm status bar every second
while true
do

    # Append results of each func one by one to a string
#    dispstr="^b#2e3440^"
#    dispstr="$dispstr$(dwm_connman)"
#    dispstr="$dispstr$(dwm_countdown)"
#    dispstr="$dispstr$(dwm_alarm)"
#    dispstr="$dispstr$(dwm_transmission)"
#    dispstr="$dispstr$(dwm_cmus)"
#    dispstr="$dispstr$(dwm_mpc)"
#    dispstr="$dispstr$(dwm_spotify)"
#    dispstr="$dispstr$(dwm_weather)"
#    dispstr="^c#a3be8c^$dispstr$(dwm_resources) "
#    dispstr="^c#ebcb8b^$dispstr$(dwm_upt) "
#    dispstr="$dispstr$(dwm_mail)"
#    dispstr="$dispstr$(dwm_backlight)"
#    dispstr="$dispstr$(dwm_alsa)"
#    dispstr="^c#d08070^$dispstr$(dwm_pulse) "
#    dispstr="^c#5e81ac^$dispstr$(dwm_battery) "
#    dispstr="$dispstr$(dwm_vpn)"
#    dispstr="$dispstr$(dwm_networkmanager)"
#    dispstr="$dispstr$(dwm_keyboard)"
#    dispstr="$dispstr$(dwm_ccurse)"
#    dispstr="^c#81a1c1^$dispstr$(dwm_date) "
#    dispstr="$dispstr$(dwm_loadavg)"
#dispstr="$dispstr$(dwm_currency)"

#    xsetroot -name "$dispstr"
xsetroot -name " ^c#bf616a^$(dwm_kernel) ^c#d08770^$(dwm_resources) ^c#ebcb8b^$(dwm_upt) ^c#8fbcbb^$(dwm_pulse) ^c#5e81ac^$(dwm_battery) ^c#88c0d0^$(dwm_date)"
    sleep 1

done
