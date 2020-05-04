#!/bin/bash 

revnum () 
{ 
    git rev-list --count HEAD
}

revnum "$@"
