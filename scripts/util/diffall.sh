#!/bin/bash 

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
