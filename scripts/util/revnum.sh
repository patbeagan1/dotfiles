#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

revnum () 
{ 
    git rev-list --count HEAD
}

revnum "$@"
trackusage.sh "$0"