#!/bin/bash 

lastfield () 
{ 
    awk -F "/" '{print $NF}'
}

lastfield "$@"
trackusage.sh "$0"