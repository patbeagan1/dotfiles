#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

set -euo pipefail
IFS=$'\n\t'

scriptname="$(basename "$0")"

help () {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help] <text>

Creates a tiny URL using itty.bitty.site service.
Compresses text content using LZMA compression and base64 encoding.

Arguments:
  text    Text content to compress and create tiny URL for

Features:
  - Uses LZMA compression for maximum compression
  - Base64 encoding for URL-safe transmission
  - Creates shareable tiny URLs for text content

Examples:
  $scriptname 'Hello World'                    # Creates tiny URL for text
  $scriptname \"$(cat document.txt)\"          # Creates tiny URL for file content
"
    if [[ ! $error_code -eq 0 ]]; then echo "Err: $error_code"; fi
}

itty () {
	echo -n "<pre>$1</pre>" | lzma -9 | base64 | xargs -0 printf "https://itty.bitty.site/#/%s\n"
}

itty "$@" || help
trackusage.sh "$0"
