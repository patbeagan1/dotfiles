compare () 
{ 
    printf "\t%s\n" "$@";
    pr -w $(tput cols) -m -t $@
}

if [[ "$1" = "-e" ]]; then shift; compare "$@"; fi
