#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

dequote () 
{ 
    eval printf %s "$1" 2> /dev/null
}
dequote "$@"
trackusage.sh "$0"