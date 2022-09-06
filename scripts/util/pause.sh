#!/bin/bash 

pause () 
{ 
    read -p "$*"
}

pause "$@"
trackusage.sh "$0"