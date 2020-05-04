#!/bin/bash 

filetype () 
{ 
    file * | sed s/,.*//
}

filetype "$@"
