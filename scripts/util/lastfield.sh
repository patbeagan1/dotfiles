#!/bin/bash 

lastfield () 
{ 
    awk -F "/" '{print $NF}'
}

lastfield "$@"
