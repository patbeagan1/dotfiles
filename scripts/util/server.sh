#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

server () 
{ 
    if [ $# -lt 2 ]; then
        port="$1";
        if [ -z "$port" ]; then
            port="8000";
        fi;
        echo Running server on "$port";
        python -m SimpleHTTPServer "$port";
    else
        echo Too many arguments.;
    fi
}

server "$@"
trackusage.sh "$0"