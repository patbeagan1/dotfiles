#!/bin/bash 

trackusage.sh "$0"
exit $(test $(machinetype.sh) == "Mac")