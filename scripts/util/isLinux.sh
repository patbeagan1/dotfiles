#!/bin/bash 

trackusage.sh "$0"
exit $(test $(machinetype.sh) == "Linux")