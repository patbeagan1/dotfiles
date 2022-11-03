#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

trackusage.sh "$0"
exit $(test $(machinetype.sh) == "Mac")