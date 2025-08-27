#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

sum () 
{ 
    echo "$1" | tr ',' '+' | bc
}

sum "$@"
trackusage.sh "$0"