#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

curr () 
{ 
    git fetch && git branch -a | grep --color=auto release-v | sed 's/remotes\/origin\///g' | sort | tail -1 | sed 's/\*//g'
}
curr "$@"
