#!/usr/bin/env bash

# SETTINGS ####################################################
# Feather font icons:
shutdown=""
reboot=""
lock=""
suspend=""
logout=""
#
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
#
CONFIRMATION_MSG="Are You Sure? : "
CONFIRMATION_OPT="Available Options: [y/yes] [n/no]"
###############################################################

LPATH="$( cd "$(dirname "$0")" ; pwd -P )"

# Rofi config
rofi_cmd="rofi -theme $LPATH/rasi/powermenu.rasi"
options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"


# Confirmation
confirm_option() {
    rofi -dmenu\
        -i\
        -no-fixed-num-lines\
        -p "$CONFIRMATION_MSG"\
        -theme $LPATH/rasi/confirm.rasi
}

# Message
msg() {
    rofi -theme "$LPATH/rasi/message.rasi" \
    -e "$CONFIRMATION_OPT"
}


# Main
chosen="$(echo -e "$options" | \
$rofi_cmd -dmenu \
-theme-str 'window {location: '$LOCATION';}' \
-selected-row 2\
)"

# Use choosen 
case $chosen in
    $lock)
        confirm=$(confirm_option &)
        if [[ $confirm == "yes" || \
              $confirm == "YES" || \
              $confirm == "y" || \
              $confirm == "Y" ]]; \
        then
            $LPATH/misc/lockscreen
        elif [[ $confirm == "no" || \
                $confirm == "NO" || \
                $confirm == "n" || \
                $aconfirmns == "N" ]]; \
            then
            ${0}
        else
            msg
            ${0}
        fi	
	    ;;    
    $shutdown)
        confirm=$(confirm_option &)
        if [[ $confirm == "yes" || \
              $confirm == "YES" || \
              $confirm == "y" || \
              $confirm == "Y" ]]; \
        then
            systemctl poweroff
        elif [[ $confirm == "no" || \
                $confirm == "NO" || \
                $confirm == "n" || \
                $aconfirmns == "N" ]]; \
        then
            ${0}
        else
            msg
            ${0}
        fi	            
        ;;
    $reboot)
        confirm=$(confirm_option &)
        if [[ $confirm == "yes" || \
              $confirm == "YES" || \
              $confirm == "y" || \
              $confirm == "Y" ]]; \
        then
            systemctl reboot
        elif [[ $confirm == "no" || \
                $confirm == "NO" || \
                $confirm == "n" || \
                $aconfirmns == "N" ]]; \
        then
            ${0}
        else
            msg
            ${0}
        fi	            
        ;;
    $suspend)
        confirm=$(confirm_option &)
        if [[ $confirm == "yes" || \
              $confirm == "YES" || \
              $confirm == "y" || \
              $confirm == "Y" ]]; \
        then
            mpc -q pause &
            amixer set Master mute &
            systemctl suspend
        elif [[ $confirm == "no" || \
                $confirm == "NO" || \
                $confirm == "n" || \
                $aconfirmns == "N" ]]; \
        then
            ${0}
        else
            msg
            ${0}
        fi	            
        ;;
    $logout)
        confirm=$(confirm_option &)
        if [[ $confirm == "yes" || \
              $confirm == "YES" || \
              $confirm == "y" || \
              $confirm == "Y" ]]; \
        then
            loginctl terminate-session ${XDG_SESSION_ID-}	
        elif [[ $confirm == "no" || \
                $confirm == "NO" || \
                $confirm == "n" || \
                $aconfirmns == "N" ]]; \
        then
            ${0}
        else
            msg
            ${0}
        fi	            
        ;;
esac