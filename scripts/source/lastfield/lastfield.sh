#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

lastfield () 
{ 
    awk -F "/" '{print $NF}'
}

lastfield "$@"
trackusage.sh "$0"