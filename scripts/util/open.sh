#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

open () 
{ 
    if [ "$(uname)" == "Linux" ]; then
        gnome-open "$@";
    else
        if [ "$(uname)" == "Darwin" ]; then
            command open "$@";
        else
            echo "This command is not supported.";
        fi;
    fi
}

open "$@"
trackusage.sh "$0"