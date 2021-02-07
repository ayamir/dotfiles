#!/bin/sh

# A dwm_bar function to read the average system load
# Alvar Penning <post@0x21.biz>
# GNU GPLv3

dwm_loadavg () {
    # LOAD_FIELDS specifies the load average values to be displayed. Values
    # within 1-3 are allowed, passed as a range (-) or comma-separated.
    # - 1: load average within the last minute
    # - 2: load average within the last five minutes
    # - 3: load average within the last fifteen minutes
    LOAD_FIELDS=1,2,3

    LOAD_AVG=$(cut -d " " -f ${LOAD_FIELDS} /proc/loadavg)

    printf "%s" "$SEP1"
    if [ "$IDENTIFIER" = "unicode" ]; then
        printf "⏱ %s" "$LOAD_AVG"
    else
        printf "AVG %s" "$LOAD_AVG"
    fi
    printf "%s\n" "$SEP2"
}

dwm_loadavg
