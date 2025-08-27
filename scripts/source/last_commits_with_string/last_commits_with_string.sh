#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

last_commits_with_string () 
{ 
    for i in $(ag "$1" | grep .php | sed 's/:.*//g' | sort | uniq );
    do
        echo "$i" && head <(gitfilehistory "$i");
    done
}

last_commits_with_string "$@"