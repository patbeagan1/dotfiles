#!/usr/bin/env bash
set -euo pipefail

if [ -z "$1" ]; then
    echo "Requires a command name, to track usages."
    exit 1;
fi
foldername="$HOME/p-tracked-commands"
mkdir -p "$foldername"
echo >> "$foldername"/"$(basename.sh "$1")"