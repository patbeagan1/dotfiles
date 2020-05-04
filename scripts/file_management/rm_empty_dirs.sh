#!/bin/bash

rm_empty_dirs () 
{ 
    find "$1" -empty -type d -delete
}

rm_empty_dirs "$@"
