#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

set -euo pipefail
IFS=$'\n\t'

help () {
    local bold='\033[1m'
    local normal='\033[0m'
    
    error_code=$?
    echo -e "
Usage: $bold imagefix.sh filename.jpg [quality] $normal
where quality is an int between 0 and 100

Density buckets are
- MDPI (1x)
- HDPI (1.5x)
- XHDPI (2x)
- XXHDPI (3x)
- XXXHDPI (4x)

This script will assume that you are giving it the XXXHDPI version of a resource, and 
generate the remaining, lower density resources.

It also will yield a webp image, which has compression like JPG, 
with the ability to have transparency.

output:
mid.minecraft-mario.jpg
minecraft-mario.jpg
minecraft-mario.jpg.100%.webp
minecraft-mario.jpg.25%.webp
minecraft-mario.jpg.37%.webp
minecraft-mario.jpg.50%.webp
minecraft-mario.jpg.75%.webp
"
    exit $error_code
}
imageFix() {
    if [ -z "${1+x}" ]; then
        return 1
    fi

    local quality="80"
    if [[ -n "${2+x}" ]]; then
        quality="$2"
    fi

    echo Proceeding with quality of "$quality"

    imageFixInner () {
        magick "$1" \
        -resize "$2" \
        -quality $quality \
        mid."$1"
        
        magick mid."$1"\
        -define webp:alpha-compression=1\
        -define webp:alpha-quality=0\
        -define webp:preprocessing=0\
        -define webp:lossless=false\
        -define webp:method=6\
        -define webp:near-lossless=70\
        -define webp:auto-filter=true\
        -resize '2000x2000>' "$1"."$2".min.webp
        # options can be seen at https://imagemagick.org/script/webp.php

        echo Finished "$1"."$2".min.webp
    }

    imageFixInner "$1" "100%"
    imageFixInner "$1" "75%"
    imageFixInner "$1" "50%"
    imageFixInner "$1" "37%"
    imageFixInner "$1" "25%"
}

imageFix "$@" || help
