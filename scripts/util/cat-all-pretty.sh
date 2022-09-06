#!/usr/bin/env bash

for i in *; do
    echo
    echo -----
    echo
    echo "# $i"
    echo
    cat "$i"
done
trackusage.sh "$0"
