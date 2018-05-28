rederr () 
{ 
    "$@" 2>&1 1>&3 | sed "s,.*,\033[31m&\e[0m," 1>&2
} 3>&1

if [[ "$1" = "-e" ]]; then shift; rederr "$@"; fi
