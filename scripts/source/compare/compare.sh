#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

compare () 
{ 
    printf "\t%s\n" "$@";
    pr -w $(tput cols) -m -t $@
}

compare "$@"
trackusage.sh "$0"