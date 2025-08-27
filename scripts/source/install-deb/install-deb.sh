#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

set -euo pipefail
IFS=$'\n\t'

scriptname="$(basename "$0")"

help () {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help] <deb_file>

Installs a Debian package (.deb file) using dpkg with sudo privileges.
This is a simple wrapper around 'sudo dpkg -i' for convenience.

Arguments:
  deb_file    Path to the .deb file to install

Examples:
  $scriptname package.deb
  $scriptname /path/to/package.deb

Note: Requires sudo privileges to install packages.
"
    if [[ ! $error_code -eq 0 ]]; then echo "Err: $error_code"; fi
}

install () {
	sudo dpkg -i "$1"
}

install "$@" || help
trackusage.sh "$0"
