#!/bin/bash 

dequote () 
{ 
    eval printf %s "$1" 2> /dev/null
}
dequote "$@"
