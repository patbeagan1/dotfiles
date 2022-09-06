#!/bin/bash 

trim () 
{ 
    sed 's/^[ 	]*//;s/[ 	]*$//'
}

trim "$@"
trackusage.sh "$0"