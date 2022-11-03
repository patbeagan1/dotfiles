#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

editlast () 
{ 
    vi $(find . -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" ")
}

editlast "$@"
trackusage.sh "$0"