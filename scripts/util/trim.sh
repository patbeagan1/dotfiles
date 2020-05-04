#!/bin/bash 

trim () 
{ 
    sed 's/^[ 	]*//;s/[ 	]*$//'
}

trim "$@"
