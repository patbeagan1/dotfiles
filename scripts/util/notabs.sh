#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

notabs () 
{ 
    if [ $# -lt 2 ]; then
        echo "Usage: notabs <file> <num spaces to use>";
    else
        n="";
        for i in $(seq 1 $2);
        do
            n+=" ";
        done;
        sed "s/	/$n/g" $1;
    fi
}

notabs "$@"
trackusage.sh "$0"