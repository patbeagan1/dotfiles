#!/bin/bash 

compare () 
{ 
    printf "\t%s\n" "$@";
    pr -w $(tput cols) -m -t $@
}

compare "$@"
trackusage.sh "$0"