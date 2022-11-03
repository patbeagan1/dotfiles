#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

pause () 
{ 
    read -p "$*"
}

pause "$@"
trackusage.sh "$0"