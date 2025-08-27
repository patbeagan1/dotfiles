#!/bin/bash
# (c) 2022 Pat Beagan: MIT License

script_content () 
{ 
    cat $(which "${1}")
}

script_content "$@"
trackusage.sh "$0"