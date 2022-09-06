#!/bin/bash 

kc () 
{ 
    kotlinc "$1" -include-runtime -d out.jar
}
kc "$@"
trackusage.sh "$0"