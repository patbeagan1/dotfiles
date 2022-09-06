#!/bin/bash

script_content () 
{ 
    cat $(which "${1}")
}

script_content "$@"
trackusage.sh "$0"