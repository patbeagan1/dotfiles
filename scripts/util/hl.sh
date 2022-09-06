#!/bin/bash 

hl () 
{ 
    grep --color=auto --color -i -E "$1|$" "$2"
}

hl "$@"
trackusage.sh "$0"