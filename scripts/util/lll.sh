#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

. $LIB_MACHINE_TYPES

lll () 
{ 
    if isMac; then
        ls
    else
        ls --color=auto -l --full-time;
    fi
}

lll "$@"
trackusage.sh "$0"