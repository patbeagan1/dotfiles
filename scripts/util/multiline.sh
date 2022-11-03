#!/bin/bash
# (c) 2022 Pat Beagan: MIT License

multiline () 
{ 
    echo "$@" | tr " " "\n"
}

multiline "$@"
trackusage.sh "$0"