#!/bin/bash
photo="'$1'"
shift
cmd="exiftool "
for i in "$@"; do
        cmd="$cmd-IPTC:Keywords+='$i' "
done
cmd="$cmd $photo"
echo "$cmd"
eval "$cmd"

trackusage.sh "$0"