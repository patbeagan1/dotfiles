nospaces () 
{ 
    rename 'y/ /_/' *
}
if [[ $0 != "-bash" ]]; then nospaces "$@"; fi
