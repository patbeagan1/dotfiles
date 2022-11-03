#!/bin/bash
# (c) 2022 Pat Beagan: MIT License

last_branch () 
{ 
    git branch --sort=committerdate
}

last_branch "$@"
