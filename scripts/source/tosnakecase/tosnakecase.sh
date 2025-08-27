#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

tosnakecase () 
{ 
    echo "$1" | perl -pe 's/([a-z0-9])([A-Z])/$1_\L$2/g'
}

tosnakecase "$@"
