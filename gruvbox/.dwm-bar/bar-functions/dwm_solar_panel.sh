#!/bin/bash
# This module can get data from a SMA Inverter.
# Its purpose is to show you how much Watts are being produced
# To make it work change the INVERTER_IP variable and your User password
# Vincenzo Petrolo <vincenzo.petrolo99@gmail.com>
# For infos on how i made it, and help or bugs, you cant contact me or
# open an issue
# GNU GPLv3

# P.s: Be careful when trying to modify urls, as they contains special
# characters that may change the behaviour of the query

dwm_solar_panel () {

	INVERTER_IP="YOUR INVERTER IP"
	PASSWORD="YOUR PASSWORD"


	if [[ -f ~/.cache/solar_panel.cache ]];
	then
		read SID < ~/.cache/solar_panel.cache
		if [ "$SID" == "null" ];
		then
			#Getting session id
		SID=$( curl -s --location --request POST "http://$INVERTER_IP/dyn/login.json" \
			--header 'Content-Type: text/plain' \
			--data-raw "{\"right\":\"usr\",\"pass\":\""$PASSWORD\""}" | jq .result.sid)
		SID=${SID//\"}
		fi
		#checks if it got a session token

		if [ "$SID" != "" ] && [ "$SID" != "null" ];
		then
			echo $SID > ~/.cache/solar_panel.cache
			WATTS=$(curl -s --location --request POST "http://$INVERTER_IP/dyn/getValues.json?sid=$SID" \
				--header 'Content-Type: text/plain' \
				--data-raw '{"destDev":[],"keys":["6100_00543100","6800_008AA200","6100_40263F00","6800_00832A00","6180_08214800","6180_08414900","6180_08522F00","6400_00543A00","6400_00260100","6800_08811F00","6400_00462E00"]}' | jq '.result."0156-76BC3EC6"."6100_40263F00"."1"[0].val')

			if [ "$WATTS" == "" ] || [ "$WATTS" == "null" ];
			then
				echo "null" > ~/.cache/solar_panel.cache
			else
				printf  "%s💡 $WATTS W %s" "$SEP1" "$SEP2"
			fi

		fi
	else
		touch ~/.cache/solar_panel.cache

		echo "null" > ~/.cache/solar_panel.cache
	fi

}
dwm_solar_panel

