#!/bin/bash 

mergetest () 
{ 
    git merge --no-commit --no-ff "$1";
    git merge --abort;
    echo "Merge aborted"
}

mergetest "$@"
