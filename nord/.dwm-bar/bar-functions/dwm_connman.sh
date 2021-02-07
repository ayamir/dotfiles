#!/bin/sh

# A dwm_bar function to show the current network connection/SSID, Wifi Strength, private IP using Connmanctl.
# procrastimax <heykeroth.dev@gmail.com>
# GNU GPLv3

# Dependencies: connman

dwm_connman () {
    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
        printf "🌐 "
    else
        printf "NET "
    fi

    # get the connmanctl service name
    # this is a UID starting with 'vpn_', 'wifi_', or 'ethernet_', we dont care for the vpn one
    # if the servicename string is empty, there is no online connection
    SERVICENAME=$(connmanctl services | grep -E "^\*AO|^\*O" | grep -Eo 'wifi_.*|ethernet_.*')

    if [ ! "$SERVICENAME" ]; then
        printf "OFFLINE"
        printf "%s\n" "$SEP2"
        return
    else
        STRENGTH=$(connmanctl services "$SERVICENAME" | sed -n -e 's/Strength =//p' | tr -d ' ')
        CONNAME=$(connmanctl services "$SERVICENAME" | sed -n -e 's/Name =//p' | tr -d ' ')
        IP=$(connmanctl services "$SERVICENAME" | grep 'IPv4 =' | awk '{print $5}' | sed -n -e 's/Address=//p' | tr -d ',')
    fi

    # if STRENGTH is empty, we have a wired connection
    if [ "$STRENGTH" ]; then
        printf "%s %s %s%%" "$IP" "$CONNAME" "$STRENGTH"
    else
        printf "%s %s" "$IP" "$CONNAME"
    fi

    printf "%s\n" "$SEP2"
}

dwm_connman
