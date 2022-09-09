#!/bin/bash 

checkcrlf () 
{ 
    dos2unix < "$1" | cmp -s - "$1"
}
checkcrlf "$@"
trackusage.sh "$0"