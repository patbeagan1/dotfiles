#!/bin/bash 

loop () 
{
    local shouldClear='false'	
    if [ $1 == "-c" ]; then
    	shouldClear="true"
	shift;
    fi;

    while :; do
        $*;
        sleep 0.5;
        if [ $shouldClear == "true" ]; then
            clear;
        fi;
    done
}

loop "$@"
