#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

checkcrlf () 
{ 
    dos2unix < "$1" | cmp -s - "$1"
}
checkcrlf "$@"
trackusage.sh "$0"