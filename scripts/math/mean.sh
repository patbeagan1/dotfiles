#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

mean () 
{ 
    math $(sum "$1")/$(count_list "$1")
}

mean "$@"
trackusage.sh "$0"