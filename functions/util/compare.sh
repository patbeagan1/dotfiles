compare () 
{ 
    printf "\t%s\n" "$@";
    pr -w $(tput cols) -m -t $@
}
