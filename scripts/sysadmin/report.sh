#!/bin/bash 

report () 
{ 
    loop.sh "clear; df; echo; w; echo; ps -e -o pcpu -o ruser -o args|sort -nr|grep -v %CPU|head -1; sleep 5"
}

report "$@"
trackusage.sh "$0"