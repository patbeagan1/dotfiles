#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

mergetest () 
{ 
    git merge --no-commit --no-ff "$1";
    git merge --abort;
    echo "Merge aborted"
}

mergetest "$@"
