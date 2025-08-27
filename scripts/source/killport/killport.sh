#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

killport () 
{ 
    sudo kill $(sudo lsof -t -i:$1)
}

killport "$@"
trackusage.sh "$0"