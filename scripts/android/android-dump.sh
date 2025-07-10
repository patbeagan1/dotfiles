#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

set -euo pipefail
IFS=$'\n\t'

scriptname="$(basename "$0")"

help () {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help]

Shows the current top activity on the connected Android device using adb.
This is useful for debugging and understanding what app is currently active.

Requires:
  - ADB (Android Debug Bridge) to be installed and configured
  - An Android device connected via USB with USB debugging enabled

Examples:
  $scriptname          # Shows current top activity
"
    exit $error_code
}

android-dump () {
	adb shell dumpsys activity top
}

android-dump "$@" || help
trackusage.sh "$0"
