#!/bin/bash 

gitsync () 
{ 
    git fetch origin "$1":"$1"
}

gitsync "$@"
