#!/bin/bash 

peek () 
{ 
    tree -L 2
}

peek "$@"
trackusage.sh "$0"