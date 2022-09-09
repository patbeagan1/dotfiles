#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

img_resize_32 ()
{
    in="$1";
    out="$2";
    convert "$in" -resize 32x32 -gravity center -extent 32x32 -fill white "$out"
}

img_resize_32 "$@"
trackusage.sh "$0"