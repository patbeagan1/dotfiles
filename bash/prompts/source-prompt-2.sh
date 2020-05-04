#!/bin/bash

# [Sat May 02 17:11 ~/.img_cache]
source-prompt-2 () 
{ 
    PS1='\[\e]0;\w\a\]\n\[\e[00;33m\][\d \A \[\e[01;35m\]\w\[\e[00;33m\]]\[\e[0m\] \[\033[1;32m\]\[\033[0m\] \n\$ '
}

source-prompt-2 "$@"
