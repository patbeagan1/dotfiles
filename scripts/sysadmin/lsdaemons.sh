#!/bin/bash 

lsdaemons () 
{ 
    ps -eo 'tty,pid,comm' | grep --color=auto ^?
}

lsdaemons "$@"
trackusage.sh "$0"