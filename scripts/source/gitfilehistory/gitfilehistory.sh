#!/bin/bash
# (c) 2022 Pat Beagan: MIT License

gitfilehistory () 
{ 
    git log -m --oneline --full-history --pretty=tformat:"%h %ar %Cred%an %Creset%s" --follow "${1}"
}

gitfilehistory "$@"
