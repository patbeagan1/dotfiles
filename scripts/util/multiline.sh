#!/bin/bash

multiline () 
{ 
    echo "$@" | tr " " "\n"
}

multiline "$@"
