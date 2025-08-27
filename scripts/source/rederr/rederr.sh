#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

rederr () 
{ 
    "$@" 2>&1 1>&3 | sed "s,.*,\033[31m&\e[0m," 1>&2
} 3>&1

rederr "$@"
trackusage.sh "$0"