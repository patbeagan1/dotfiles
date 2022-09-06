#!/usr/bin/env zsh

cat "$1" | grep -v '#' | grep -v "^$"
trackusage.sh "$0"