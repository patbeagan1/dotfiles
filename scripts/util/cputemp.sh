#!/bin/bash

. $LIB_MACHINE_TYPES

cputemp ()
{
    if isMac; then
        check_install.sh iStats
        c=$(iStats | grep 'CPU temp' | sed s/[a-zA-Z\ :]*// | sed s/°.*//);
        echo "9*$c/5+32" | bc -l;
    else
        exit 1
    fi
}
cputemp "$@"
