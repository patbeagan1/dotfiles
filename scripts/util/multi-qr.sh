#!/usr/bin/env zsh

set -euo pipefail

scriptname="$(basename "$0")"
help() {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help] <file>

Creates multiple QR codes from a large file by splitting it into chunks.
Each chunk is converted to a tiny URL and then to a QR code.

Process:
1. Splits input file into 2KB chunks
2. Converts each chunk to tiny URL using itty.bitty.site
3. Generates QR code for each tiny URL
4. Combines all QR codes into a single vertical image
5. Opens the combined image

Arguments:
  file    File to split and convert to QR codes

Examples:
  $scriptname large_document.txt
  $scriptname /path/to/big_file.pdf
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
