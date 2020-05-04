#!/bin/bash 

getbranch () 
{ 
    printf $(git rev-parse --abbrev-ref HEAD)
}
getbranch "$@"
