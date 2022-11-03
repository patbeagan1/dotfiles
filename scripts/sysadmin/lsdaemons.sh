#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

lsdaemons () 
{ 
    ps -eo 'tty,pid,comm' | grep --color=auto ^?
}

lsdaemons "$@"
trackusage.sh "$0"