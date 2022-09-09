#!/bin/bash 

sum () 
{ 
    echo "$1" | tr ',' '+' | bc
}

sum "$@"
trackusage.sh "$0"