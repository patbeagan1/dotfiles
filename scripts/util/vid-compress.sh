#!/usr/bin/env zsh

set -euo pipefail

scriptname="$(basename "$0")"
help() {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help]

Compresses a video file with h265 compression 
https://unix.stackexchange.com/questions/28803/how-can-i-reduce-a-videos-size-with-ffmpeg

Good for compressing videos so that they fit in github PRs. 
"
    exit $error_code
}

main() {

    emulate -L zsh
    zmodload zsh/zutil || return 1

    local help
    zparseopts -D -F -K -- \
        {h,-help}=help ||
        return 1

    if (($#help)); then help; fi

vid-compress () {
	ffmpeg -i "$1" -vcodec libx265 -crf 28 output.mp4
}

    vid-compress "$@" || help
}

main "$@" || help
trackusage.sh "$0"
