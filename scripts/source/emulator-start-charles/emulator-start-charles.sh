#!/usr/bin/env zsh

set -euo pipefail

scriptname="$(basename "$0")"
help() {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help]

Starts an Android emulator with Charles Proxy configured for network debugging.
Automatically detects your local IP address and configures the emulator to use
Charles Proxy running on port 8888.

Features:
  - Automatically finds your local IP address
  - Uses fzf to select an emulator from available AVDs
  - Configures HTTP proxy for network traffic inspection
  - Optimized network settings (no delay, full speed)

Requires:
  - Android SDK with emulator tools
  - Charles Proxy running on port 8888
  - fzf for emulator selection
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

emulator-start-charles () {
	local ip_address="$(ifconfig | grep 192 | sed 's/.*inet//g' | sed 's/netmask.*//g')" local emu="$(emulator -list-avds | fzf)" 
	emulator -netdelay none -netspeed full -http-proxy http://"$ip_address":8888 -avd "$emu"
}

    emulator-start-charles "$@" || help
}

main "$@" || help
trackusage.sh "$0"
