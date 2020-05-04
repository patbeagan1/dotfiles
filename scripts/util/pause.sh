#!/bin/bash 

pause () 
{ 
    read -p "$*"
}

pause "$@"
