#!/bin/bash 

mean () 
{ 
    math $(sum "$1")/$(count_list "$1")
}

mean "$@"
trackusage.sh "$0"