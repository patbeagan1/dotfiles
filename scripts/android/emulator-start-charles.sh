#!/usr/bin/env zsh

set -euo pipefail

scriptname="$0"
help() {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help]

No help message yet
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
