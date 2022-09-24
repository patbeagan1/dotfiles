#!/usr/bin/env zsh

set -euo pipefail
IFS=$'\n\t'

help() {
    error_code=$?
    echo "
---
Converts a list of images into a minecraft painting resource pack

Please make sure that any listed images are valid.
"
    exit $error_code
}

csv=(
    '16,16,alban'
    '16,16,aztec'
    '16,16,aztec2'
    '16,16,bomb'
    '16,16,kebab'
    '16,16,plant'
    '16,16,wasteland'
    '32,16,courbet'
    '32,16,pool'
    '32,16,sea'
    '32,16,creebet'
    '32,16,sunset'
    '16,32,graham'
    '16,32,wanderer'
    '32,32,bust'
    '32,32,match'
    '32,32,skull_and_roses'
    '32,32,stage'
    '32,32,void'
    '32,32,wither'
    '64,32,fighters'
    '64,48,donkey_kong'
    '64,48,skeleton'
    '64,64,burning_skull'
    '64,64,pigscene'
    '64,64,pointer'
)

minecraft-photopack() {

    local timestamp=$(date +%s)
    local output_folder="painting-pack-$timestamp"
    mkdir "$output_folder"
    echo '{
  "pack": {
    "pack_format": 9,
    "description":'"Painting pack $timestamp"'
  }
}' >> "$output_folder"/pack.mcmeta
    echo 'Generated painting pack' >> "$output_folder"/README.txt
    mkdir -p "$output_folder"/assets/minecraft/textures/painting
    wget -O "$output_folder"/pack.png https://upload.wikimedia.org/wikipedia/commons/5/57/Tiny6pixel.png

    local scale=3

    for i in $csv; do
        # read one line
        IFS=, read -rA array <<<"$i"

        local filename="unchanged"
        if [ $# -gt 0 ]; then
            filename="$1"

            array[1]=$(( $array[1] * $scale ))
            array[2]=$(( $array[2] * $scale ))

            magick \
                convert $filename \
                -resize $array[1]x$array[2]^ \
                -gravity center \
                -extent $array[1]x$array[2] \
                -flatten \
                -strip \
                -colorspace RGB \
                -depth 24 \
                -define png:compression-filter=1 \
                -define png:compression-level=9 \
                -define png:compression-strategy=2 \
                unoptimized_$array[3].png || return 1

                local input=unoptimized_$array[3].png
                local output="$output_folder"/assets/minecraft/textures/painting/$array[3].png

                if which pngcrush &>/dev/null; then
                    pngcrush "$input" "$output"
                else
                    mv "$input" "$output"
                fi

                rm "$input"
            shift
        fi

        echo "$array[@] = $filename"
    done
}

minecraft-photopack "$@" || help
trackusage.sh "$0"
