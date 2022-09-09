#!/bin/bash 

manbook () 
{ 
    cat $1 | groff -man -Tps > book.ps
}

manbook "$@"
trackusage.sh "$0"