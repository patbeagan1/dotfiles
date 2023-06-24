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

scan-lan () {
	echo
	parallel \
		-P 128 \
		'ping -nqc 1 -W 2 192.168.1.{} \
		| sed -z "s/\n//g" \
		| uniq \
		| grep -v "0 received" \
		| sed -e "s/---/\n/g" \
		| grep PING \
		2> /dev/null \
		' ::: {0..255} \
		| cut -d' ' -f2 \
		| sort
	echo
	echo "I am `pretty_ip`"
}

    scan-lan "$@" || help
}

main "$@" || help
trackusage.sh "$0"
