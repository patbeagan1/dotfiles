#!/bin/bash 

killport () 
{ 
    sudo kill $(sudo lsof -t -i:$1)
}

killport "$@"
