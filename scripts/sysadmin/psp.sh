#!/bin/bash 

psp () 
{ 
    ps awwfux | less -S
}

psp "$@"
