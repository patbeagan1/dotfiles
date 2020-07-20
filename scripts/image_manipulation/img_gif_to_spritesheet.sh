#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

img_gif_to_spritesheet ()
{
    in="$1";
    out="$2";

    mkdir -p out-"$out"
    cd out-"$out"

    convert ../"$in" -resize 64x64 -gravity center -extent 64x64 -fill transparent "interim.png"
    montage "interim-"* -background transparent -geometry 64x64+0+0 "$out"
}

img_gif_to_spritesheet "$@"