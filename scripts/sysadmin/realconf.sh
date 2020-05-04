#!/bin/bash 

realconf () 
{ 
    cat $1 | grep --color=auto --color=auto -v '#' | grep --color=auto --color=auto -v '^$'
}

realconf "$@"
