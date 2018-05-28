quote () 
{ 
    local quoted=${1//\'/\'\\\'\'};
    printf "'%s'" "$quoted"
}

if [[ "$1" = "-e" ]]; then shift; quote "$@"; fi
