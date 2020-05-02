#!/bin/bash 

isLinux () 
{ 
    if [ "Linux" = $(machinetype) ]; then
        return 0;
    else
        return 1;
    fi
}

isLinux "$@"
