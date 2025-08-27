#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

set -euo pipefail
IFS=$'\n\t'

help() {
    error_code=$?
    echo "
Caches information from a given URL, at a given cache location. 
The default cache location is ~/p-cache

The script will return the location where the information is cached.
Subsequent calls with the same address will skip downloading and just return the cache file name.
"
    if [[ ! $error_code -eq 0 ]]; then echo "Err: $error_code"; fi
}

function cache() {
    if [ ! $# -eq 1 ]; then
        return 1
    fi
    local cache_location="$HOME/p-cache"
    local basename_original="$1"
    local basename="$(sed 's/\//-/g' <(echo "$1"))"
    local filename="$cache_location/$basename"
    mkdir -p "$cache_location"

    if [ -f "$filename" ]; then
        echo "$filename"
    else
        wget \
            --quiet \
            -P "$cache_location" \
            --continue \
            -O "$filename" \
            "$basename_original"
        if [ $? -eq 0 ]; then
            echo "$filename"
        else
            return 1
        fi
    fi
}

cache "$@" || help
trackusage.sh "$0"
