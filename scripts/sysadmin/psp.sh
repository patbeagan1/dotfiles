#!/bin/bash 

psp () 
{ 
    ps awwfux | less -S
}

psp "$@"
trackusage.sh "$0"