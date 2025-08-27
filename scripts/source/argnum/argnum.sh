#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

argnum () 
{ 
    printf "%d args:" $#;
    printf " <%s>" "$@";
    echo
}
argnum "$@"
trackusage.sh "$0"