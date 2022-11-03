#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

realconf () 
{ 
    cat $1 | grep --color=auto --color=auto -v '#' | grep --color=auto --color=auto -v '^$'
}

realconf "$@"
trackusage.sh "$0"