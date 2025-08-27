#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

gitfile () 
{ 
    git status --porcelain | sed s/^...//
}

gitfile "$@"
