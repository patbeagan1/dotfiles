lsdaemons () 
{ 
    ps -eo 'tty,pid,comm' | grep --color=auto ^?
}

if [[ "$1" = "-e" ]]; then shift; lsdaemons "$@"; fi
