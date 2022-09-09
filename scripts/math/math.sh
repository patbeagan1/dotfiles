#!/bin/bash 

math () 
{ 
    echo "$*" | bc -l
}

math "$@"
trackusage.sh "$0"