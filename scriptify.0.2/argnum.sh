argnum () 
{ 
    printf "%d args:" $#;
    printf " <%s>" "$@";
    echo
}

if [[ "$1" = "-e" ]]; then shift; argnum "$@"; fi
