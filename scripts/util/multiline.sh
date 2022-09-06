#!/bin/bash

multiline () 
{ 
    echo "$@" | tr " " "\n"
}

multiline "$@"
trackusage.sh "$0"