#!/bin/sh

# A dwm_status function that displays the status of countdown.sh
# Joe Standring <git@joestandring.com>
# GNU GPLv3

# Dependencies: https://github.com/joestandring/countdown

dwm_countdown () {
    for f in /tmp/countdown.*; do
        if [ -e "$f" ]; then
            printf "%s" "$SEP1"
            if [ "$IDENTIFIER" = "unicode" ]; then
                printf "⏳ %s" "$(tail -1 /tmp/countdown.*)"
            else
                printf "CDN %s" "$(tail -1 /tmp/countdown.*)"
            fi
            printf "%s\n" "$SEP2"

            break
        fi
    done
}

dwm_countdown
