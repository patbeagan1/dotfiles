#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

kc () 
{ 
    kotlinc "$1" -include-runtime -d out.jar
}
kc "$@"
trackusage.sh "$0"