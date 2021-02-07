#!/bin/sh

# A dwm_bar function that shows the current artist, track, position, duration, and status from cmus
# Joe Standring <git@joestandring.com>
# GNU GPLv3

# Dependencies: cmus

dwm_cmus () {
    if ps -C cmus > /dev/null; then
        ARTIST=$(cmus-remote -Q | grep -a '^tag artist' | awk '{gsub("tag artist ", "");print}')
        TRACK=$(cmus-remote -Q | grep -a '^tag title' | awk '{gsub("tag title ", "");print}')
        POSITION=$(cmus-remote -Q | grep -a '^position' | awk '{gsub("position ", "");print}')
        DURATION=$(cmus-remote -Q | grep -a '^duration' | awk '{gsub("duration ", "");print}')
        STATUS=$(cmus-remote -Q | grep -a '^status' | awk '{gsub("status ", "");print}')
        SHUFFLE=$(cmus-remote -Q | grep -a '^set shuffle' | awk '{gsub("set shuffle ", "");print}')

        if [ "$IDENTIFIER" = "unicode" ]; then
            if [ "$STATUS" = "playing" ]; then
                STATUS="▶"
            else
                STATUS="⏸"
            fi

            if [ "$SHUFFLE" = "true" ]; then
                SHUFFLE=" 🔀"
            else
                SHUFFLE=""
            fi
        else
            if [ "$STATUS" = "playing" ]; then
                STATUS="PLA"
            else
                STATUS="PAU"
            fi

            if [ "$SHUFFLE" = "true" ]; then
                SHUFFLE=" S"
            else
                SHUFFLE=""
            fi
        fi
        
        printf "%s%s %s - %s " "$SEP1" "$STATUS" "$ARTIST" "$TRACK"
        printf "%0d:%02d/" $((POSITION%3600/60)) $((POSITION%60))
        printf "%0d:%02d" $((DURATION%3600/60)) $((DURATION%60))
        printf "%s%s\n" "$SHUFFLE" "$SEP2"
    fi
}

dwm_cmus
