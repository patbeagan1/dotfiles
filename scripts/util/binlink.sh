#!/bin/bash 

binlink () 
{ 
    ln -s $(pwd)/$1 /usr/local/bin/$1
}

binlink "$@"
trackusage.sh "$0"