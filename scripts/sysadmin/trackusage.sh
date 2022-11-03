#!/usr/bin/env bash
# (c) 2022 Pat Beagan: MIT License
set -euo pipefail

# Lists by reversed size because we keep track of the number of bytes in each file
# We care the most about the most used ones.

foldername="$HOME/p-tracked-commands"
if [ "$1" == "-h" ]; then
    echo "Options are:"
    echo "-a print all"
    echo "-m print most used"
elif [ "$1" == "-a" ]; then
    echo Printing all tracked commands
    ls -lSrc "$foldername"
    exit 0
elif [ "$1" == "-m" ]; then
    echo Printing most used tracked commands
    ls -lSrc "$foldername" | tail
    exit 0
fi

trackusage-impl.sh $(basename.sh "$1")
