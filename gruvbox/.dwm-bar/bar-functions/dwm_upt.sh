#!/bin/bash

dwm_upt() {
    printf "%s" "$SEP1"
    upt="$(uptime --pretty | sed -e 's/up //g' -e 's/ days/d/g' -e 's/ day/d/g' -e 's/ hours/h/g' -e 's/ hour/h/g' -e 's/ minutes/m/g' -e 's/, / /g')"
#    echo -e "  $upt "
    printf " %s" "$upt"
    printf "%s\n" "$SEP2"
}

dwm_upt
