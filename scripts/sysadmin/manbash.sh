#!/bin/bash 

manbash () 
{ 
    man -P "less '+/^ *'${1}" bash
}

manbash "$@"
trackusage.sh "$0"