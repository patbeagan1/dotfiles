#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

manbash () 
{ 
    man -P "less '+/^ *'${1}" bash
}

manbash "$@"
trackusage.sh "$0"