#!/bin/bash 

weather () 
{ 
    curl http://wttr.in/Boston
}

weather "$@"
