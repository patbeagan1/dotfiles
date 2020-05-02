#!/bin/bash 

isMac () 
{ 
    if [ "Mac" = $(machinetype) ]; then
        return 0;
    else
        return 1;
    fi
}

isMac "$@"
