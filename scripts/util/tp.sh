#!/bin/bash 

tp () 
{ 
    PS1='\[\e]0;\w\a\]\n\[\e[00;33m\][\d \A \[\e[01;35m\]\w\[\e[00;33m\]]\[\e[0m\]$(__git_ps1 " \[\033[1;32m\](%s)\[\033[0m\]") $(__awsenv_ps1)\n\$ '
}

tp "$@"
trackusage.sh "$0"