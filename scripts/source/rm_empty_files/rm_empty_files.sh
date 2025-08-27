#!/bin/bash
# (c) 2022 Pat Beagan: MIT License

rm_empty_files () 
{ 
    find "$1" -empty -type -f -delete
}

rm_empty_files "$@"
trackusage.sh "$0"