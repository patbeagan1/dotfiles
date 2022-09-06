#!/bin/bash 

kr () 
{ 
    java -jar "$1"
}

kr "$@"
trackusage.sh "$0"