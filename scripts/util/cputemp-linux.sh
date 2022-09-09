#!/usr/bin/env zsh 
if isMac.sh; then 
	echo "This script is only for linux. Exiting."
	exit 1
fi
paste \
	<(cat /sys/class/thermal/thermal_zone*/type)  \
       	<(cat /sys/class/thermal/thermal_zone*/temp) |\
       	column -s $'\t' -t |\
       	sed 's/\(.\)..$/.\1°C/'   
trackusage.sh "$0"