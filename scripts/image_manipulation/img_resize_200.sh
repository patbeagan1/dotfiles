#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

img_resize ()
{
    in="$1";
    out="$2";
    convert "$in" -resize 200x200 -gravity center -extent 200x200 -fill black "$out"
}

img_resize "$@"
trackusage.sh "$0"