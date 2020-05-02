#!/bin/bash 

math () 
{ 
    echo "$*" | bc -l
}

math "$@"
