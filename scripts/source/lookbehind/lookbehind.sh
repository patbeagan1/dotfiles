#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

lookbehind () 
{ 
    printf "((?!%s).)*" "$1"
}

lookbehind "$@"
trackusage.sh "$0"