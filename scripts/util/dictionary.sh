#!/bin/bash 

dictionary () 
{ 
    curl dict://dict.org/d:$1
}

dictionary "$@"
