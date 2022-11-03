#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

set -euo pipefail
IFS=$'\n\t'

help () {
    error_code=$?
    echo "
No help message yet
"
    exit $error_code
}

android-dump () {
	adb shell dumpsys activity top
}

android-dump "$@" || help
trackusage.sh "$0"
