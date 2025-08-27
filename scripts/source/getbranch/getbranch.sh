#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

getbranch () 
{ 
    printf $(git rev-parse --abbrev-ref HEAD)
}
getbranch "$@"
