#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

binlink () 
{ 
    ln -s $(pwd)/$1 /usr/local/bin/$1
}

binlink "$@"
trackusage.sh "$0"