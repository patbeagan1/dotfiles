#!/bin/bash 

nospaces () 
{ 
    rename 'y/ /_/' *
}

nospaces "$@"
