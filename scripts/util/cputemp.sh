#!/bin/bash 

cputemp () 
{ 
    if isMac; then
        c=$(iStats | grep 'CPU temp' | sed s/[a-zA-Z\ :]*// | sed s/°.*//);
        echo "9*$c/5+32" | bc -l;
    fi
}
cputemp "$@"
