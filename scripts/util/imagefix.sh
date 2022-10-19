#!/usr/bin/env zsh

set -euo pipefail
IFS=$'\n\t'

help () {
    error_code=$?
    echo "
No help message yet
"
    exit $error_code
}
imageFix() {
    imageFixInner () {
        magick "$1" -resize "$2" mid."$1"
        magick mid."$1"\
        -quality 50\
        -define webp:alpha-compression=1\
        -define webp:alpha-quality=0\
        -define webp:preprocessing=0\
        -define webp:lossless=false\
        -define webp:target-size=500000\
        -define webp:method=6\
        -define webp:near-lossless=70\
        -define webp:auto-filter=true\
        -resize '2000x2000>' "$1"."$2".min.webp
    }

    imageFixInner "$1" "75%"
    imageFixInner "$1" "50%"
    imageFixInner "$1" "37%"
    imageFixInner "$1" "25%"
}

imageFix "$@" || help
trackusage.sh "$0"
