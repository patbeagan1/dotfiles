#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

kr () 
{ 
    java -jar "$1"
}

kr "$@"
trackusage.sh "$0"