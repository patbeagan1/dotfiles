#!/usr/bin/env zsh

set -euo pipefail
IFS=$'\n\t'

help() {
	error_code=$?
	echo "
'wget -i' but with rate limiting.
Downloads a list of URLs politely - limiting bandwidth per second and only sending 2 requests per second.
Takes one argument - a filename for a file that contains a list of urls
"
	if [[ ! $error_code -eq 0 ]]; then echo "Err: $error_code"; fi
}

f() {
	if [ $# != 1 ]; then
		return 1
	fi
	while IFS=$'\n' read -r line; do
		cmd="$(echo $line |
			sed 'p;s/\//-/g' |
			sed 'N;s/\n/ -O /' |
			sed 's/^/wget --limit-rate=100k /g')" 
		eval "$cmd"
		sleep 0.5
	done < "$1"
}

f "$@" || help
trackusage.sh "$0"
