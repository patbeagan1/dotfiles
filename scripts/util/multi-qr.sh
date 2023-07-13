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

qr () {
    local filename="/tmp/qr-output-$(python3 -c 'import time; print(time.time())').png"
    qrencode -l L -v 1 -o "$filename" "$1" && echo "$filename" >> x0_qrfile.txt
}
function qr_itty () { qr $(itty.sh "$1"); }
function qr_itty_cat () { qr_itty "`cat $1`"; }

main() {

    emulate -L zsh
    zmodload zsh/zutil || return 1

    local help
    zparseopts -D -F -K -- \
        {h,-help}=help ||
        return 1

    if (($#help)); then help; fi

multi-qr () {
	rm x0*
	split -d -b2k -a6 "$1"
	for i in x000*
	do
		echo "$i"
		qr_itty_cat "$i"
	done
	convert -append @x0_qrfile.txt x0_out.png
	open x0_out.png
}

    multi-qr "$@" || help
}

main "$@" || help
trackusage.sh "$0"
