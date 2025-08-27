#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

rec () 
{ 
    script ~/Downloads/typescript-`date | sed 's/ /-/g'`.log;
    history > ~/Downloads/"$(echo "history-`date`.log" | sed s/\ /_/g)"
}

rec "$@"
trackusage.sh "$0"