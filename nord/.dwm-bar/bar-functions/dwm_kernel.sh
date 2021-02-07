#!/bin/bash

dwm_kernel() {
    printf "%s" "$SEP1"
    version="$(uname -r)"
    printf " %s" "$version"
    printf "%s\n" "$SEP2"
}

dwm_kernel
