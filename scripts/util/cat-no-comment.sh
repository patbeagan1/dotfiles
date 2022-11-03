#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

cat "$1" | grep -v '#' | grep -v "^$"
trackusage.sh "$0"