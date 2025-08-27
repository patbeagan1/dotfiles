#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

manbook () 
{ 
    cat $1 | groff -man -Tps > book.ps
}

manbook "$@"
trackusage.sh "$0"