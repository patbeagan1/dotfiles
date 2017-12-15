lsdaemons () 
{ 
    ps -eo 'tty,pid,comm' | grep --color=auto ^?
}
if [[ $0 != "-bash" ]]; then lsdaemons "$@"; fi
