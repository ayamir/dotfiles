#!/bin/sh

# Dependancies: wpa_cli

dwm_wpa() {
   CONSTATE=$(wpa_cli status | sed -n '/wpa_state/s/^.*=//p')

   case $CONSTATE in
      'COMPLETED')
         CONSSID=$(wpa_cli status | sed -n '/\<ssid\>/s/^.*=//p')
         CONIP=$(wpa_cli status | sed -n '/ip_address/s/^.*=//p')
         CONRSSI=$(wpa_cli signal_poll | sed -n '/AVG_RSSI/s/^.*=//p')
         if [ "$CONRSSI" -gt -35 ]; then   
            printf "%s" "$SEP1"
            printf "\uF927 %s %s" "$CONSSID" "$CONIP"
            printf "%s\n" "$SEP2"
         elif [ "$CONRSSI" -ge -55 ] && [ "$CONRSSI" -lt -35 ]; then   
            printf "%s" "$SEP1"
            printf "\uF924 %s %s" "$CONSSID" "$CONIP"
            printf "%s\n" "$SEP2"
         elif [ "$CONRSSI" -ge -75 ] && [ "$CONRSSI" -lt -55 ]; then   
            printf "%s" "$SEP1"
            printf "\uF921 %s %s" "$CONSSID" "$CONIP"
            printf "%s\n" "$SEP2"
         else 
            printf "%s" "$SEP1"
            printf "\uF91E %s %s" "$CONSSID" "$CONIP"
            printf "%s\n" "$SEP2"
         fi
         ;;
#======================================================================#
      'DISCONNECTED')
         printf "%s" "$SEP1"
         printf "\uF92D %s" "$CONSTATE"
         printf "%s\n" "$SEP2"
         ;;
      'INTERFACE_DISABLED')
         printf "%s" "$SEP1"
         printf "\uF92D %s" "$CONSTATE"
         printf "%s\n" "$SEP2"
         ;;
#======================================================================#
      'SCANNING')
         printf "%s" "$SEP1"
         printf "\uF92A %s" "$CONSTATE"
         printf "%s\n" "$SEP2"
         ;;
      'ASSOCIATING')
         printf "%s" "$SEP1"
         printf "\uF92A %s" "$CONSTATE"
         printf "%s\n" "$SEP2"
         ;;
      'ASSOCIATED')
         printf "%s" "$SEP1"
         printf "\uF92A %s" "$CONSTATE"
         printf "%s\n" "$SEP2"
         ;;
      'AUTHENTICATING')
         printf "%s" "$SEP1"
         printf "\uF92A %s" "$CONSTATE"
         printf "%s\n" "$SEP2"
         ;;
#======================================================================#
      '4WAY_HANDSHAKE')
         printf "%s" "$SEP1"
         printf "\uF92B %s" "$CONSTATE"
         printf "%s\n" "$SEP2"
         ;;
      'GROUP_HANDSHAKE')
         printf "%s" "$SEP1"
         printf "\uF92B %s" "$CONSTATE"
         printf "%s\n" "$SEP2"
         ;;
      'INACTIVE')
         printf "%s" "$SEP1"
         printf "\uF92B %s" "$CONSTATE"
         printf "%s\n" "$SEP2"
         ;;
   esac
}

dwm_wpa
