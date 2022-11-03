#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

quote () 
{ 
    local quoted=${1//\'/\'\\\'\'};
    printf "'%s'" "$quoted"
}

quote "$@"
trackusage.sh "$0"