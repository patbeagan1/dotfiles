#!/bin/bash
# (c) 2022 Pat Beagan: MIT License

set -euo pipefail
IFS=$'\n\t'

img_resize_64 ()
{
    in="$1";
    out="$2";
    convert "$in" -resize 64x64 -gravity center -extent 64x64 -fill transparent "$out"
}

img_resize_64 "$@"
trackusage.sh "$0"