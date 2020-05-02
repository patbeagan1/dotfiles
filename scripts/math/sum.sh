#!/bin/bash 

sum () 
{ 
    echo "$1" | tr ',' '+' | bc
}

sum "$@"
