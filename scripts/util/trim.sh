#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

trim () 
{ 
    sed 's/^[ 	]*//;s/[ 	]*$//'
}

trim "$@"
trackusage.sh "$0"