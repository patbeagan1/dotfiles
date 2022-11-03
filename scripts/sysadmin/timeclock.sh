#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

timeclock () 
{ 
    printf "%s\t|%s\n" "$1" "`date`" >> ~/timeclock.log
}

timeclock "$@"
