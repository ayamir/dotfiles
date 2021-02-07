#!/bin/sh

# A dwm_status function that displays upcoming alarms from alarm.sh
# Joe Standring <git@joestandring.com>
# GNU GPLv3

# Dependencies: https://github.com/joestandring/alarm

dwm_alarm () {
    for f in /tmp/alarm.*; do
        if [ -e "$f" ]; then
            printf "%s" "$SEP1"
            if [ "$IDENTIFIER" = "unicode" ]; then
                printf "⏰ %s" "$(cat /tmp/alarm.*)"
            else
                printf "ALM %s" "$(cat /tmp/alarm.*)"
            fi
            printf "%s\n" "$SEP2"

            break
        fi
    done
}

dwm_alarm
