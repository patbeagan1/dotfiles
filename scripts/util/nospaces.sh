#!/bin/bash 

nospaces () 
{ 
    rename 'y/ /_/' *
}

nospaces "$@"
trackusage.sh "$0"