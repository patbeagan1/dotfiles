#!/bin/bash 

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