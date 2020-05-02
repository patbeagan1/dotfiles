#!/bin/bash 

quote () 
{ 
    local quoted=${1//\'/\'\\\'\'};
    printf "'%s'" "$quoted"
}

quote "$@"
