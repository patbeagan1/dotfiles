#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

dictionary () 
{ 
    curl "dict://dict.org/d:$1"
}

dictionary "$@"
trackusage.sh "$0"