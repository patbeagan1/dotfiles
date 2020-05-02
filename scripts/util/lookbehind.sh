#!/bin/bash 

lookbehind () 
{ 
    printf "((?!%s).)*" "$1"
}

lookbehind "$@"
