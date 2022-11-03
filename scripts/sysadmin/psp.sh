#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

psp () 
{ 
    ps awwfux | less -S
}

psp "$@"
trackusage.sh "$0"