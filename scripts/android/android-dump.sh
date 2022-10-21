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

android-dump () {
	adb shell dumpsys activity top
}

android-dump "$@" || help
trackusage.sh "$0"
