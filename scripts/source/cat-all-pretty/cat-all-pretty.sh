#!/usr/bin/env bash
# (c) 2022 Pat Beagan: MIT License

for i in *; do
    echo
    echo -----
    echo
    echo "# $i"
    echo
    cat "$i"
done
trackusage.sh "$0"
