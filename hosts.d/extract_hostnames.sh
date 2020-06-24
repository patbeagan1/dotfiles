#!/bin/bash

# works on a list of URLs, not on hosts files.
#eg,
#  https://google.com/123
#  https://yahoo.com/xyz
#becomes
#  google.com
#  yahoo.com

cat "$1" \
    | xargs -I % echo % \
    | awk -F/ '{print $3}' \
    | rev \
    | sort \
    | rev \
    | uniq
