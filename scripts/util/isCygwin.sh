#!/bin/bash 

isCygwin () 
{ 
    if [ "Cygwin" = $(machinetype) ]; then
        return 0;
    else
        return 1;
    fi
}

isCygwin "$@"
