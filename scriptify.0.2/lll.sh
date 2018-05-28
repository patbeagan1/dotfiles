lll () 
{ 
    if [ $(uname) = "Darwin" ]; then
        ls --color=auto -lT;
    else
        ls --color=auto -l --full-time;
    fi
}

if [[ "$1" = "-e" ]]; then shift; lll "$@"; fi
