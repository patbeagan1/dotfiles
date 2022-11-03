#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

filetype () 
{ 
    file * | sed s/,.*//
}

filetype "$@"
