#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

nospaces () 
{ 
    rename 'y/ /_/' *
}

nospaces "$@"
trackusage.sh "$0"