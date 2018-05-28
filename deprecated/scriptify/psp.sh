psp () 
{ 
    ps awwfux | less -S
}
if [[ $0 != "-bash" ]]; then psp "$@"; fi
