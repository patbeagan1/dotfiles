#!/bin/bash 

argnum () 
{ 
    printf "%d args:" $#;
    printf " <%s>" "$@";
    echo
}
argnum "$@"
