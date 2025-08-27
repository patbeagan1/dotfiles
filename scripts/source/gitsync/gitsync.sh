#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

gitsync () 
{ 
    git fetch origin "$1":"$1"
}

gitsync "$@"
