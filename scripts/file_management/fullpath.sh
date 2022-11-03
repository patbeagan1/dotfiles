#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

fullpath () 
{ 
    case "$1" in 
        /*)
            printf '%s\n' "$1"
        ;;
        *)
            printf '%s\n' "$PWD/$1"
        ;;
    esac
}

fullpath "$@"
trackusage.sh "$0"