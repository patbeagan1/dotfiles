#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

set -euo pipefail
IFS=$'\n\t'

help () {
    error_code=$?
    echo "
No help message yet
"
    if [[ ! $error_code -eq 0 ]]; then echo "Err: $error_code"; fi
}

itty () {
	echo -n "<pre>$1</pre>" | lzma -9 | base64 | xargs -0 printf "https://itty.bitty.site/#/%s\n"
}

itty "$@" || help
trackusage.sh "$0"
