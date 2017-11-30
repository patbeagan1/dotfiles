compare () 
{ 
    printf "\t%s\n" "$@";
    pr -w $(tput cols) -m -t $@
}
if [[ $0 != "-bash" ]]; then compare "$@"; fi
