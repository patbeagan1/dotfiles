#!/bin/bash 

gitfile () 
{ 
    git status --porcelain | sed s/^...//
}

gitfile "$@"
