#!/bin/bash 

loop () 
{
    local shouldClear='false'	
    if [ "$1" == "-c" ]; then
    	shouldClear="true"
	shift;
    fi;

    while :; do
        eval $@;
        sleep 0.5;
        if [ $shouldClear == "true" ]; then
            clear;
        fi;
    done
}

loop "$*"
trackusage.sh "$0"
