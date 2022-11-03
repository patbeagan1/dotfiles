#!/bin/bash
# (c) 2022 Pat Beagan: MIT License

rm_empty_dirs () 
{ 
    find "$1" -empty -type d -delete
}

rm_empty_dirs "$@"
trackusage.sh "$0"