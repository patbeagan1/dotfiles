#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

jj () 
{ 
    javac ${1};
    java $(echo ${1} | sed s/\.java// )
}

jj "$@"
trackusage.sh "$0"