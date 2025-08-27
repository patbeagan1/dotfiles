#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

hl () 
{ 
    grep --color=auto --color -i -E "$1|$" "$2"
}

hl "$@"
trackusage.sh "$0"