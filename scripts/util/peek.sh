#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

peek () 
{ 
    tree -L 2
}

peek "$@"
trackusage.sh "$0"