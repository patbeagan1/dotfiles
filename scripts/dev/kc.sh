#!/bin/bash 

kc () 
{ 
    kotlinc "$1" -include-runtime -d out.jar
}
kc "$@"
