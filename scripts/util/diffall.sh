#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

diffall () 
{ 
    for i in *;
    do
        for j in *;
        do
            echo === $i \|\| $j;
            diff $i $j;
        done;
    done
}

diffall "$@"
trackusage.sh "$0"