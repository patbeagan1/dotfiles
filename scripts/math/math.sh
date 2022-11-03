#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

math () 
{ 
    echo "$*" | bc -l
}

math "$@"
trackusage.sh "$0"