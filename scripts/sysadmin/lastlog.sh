#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

lastlog () 
{ 
    cd /var/log;
    less $(ls -1t | head -1)
}

lastlog "$@"
trackusage.sh "$0"