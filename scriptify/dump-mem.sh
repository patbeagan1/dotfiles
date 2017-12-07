dump-mem () 
{ 
    sudo dd if=/dev/mem | cat | strings
}
if [[ $0 != "-bash" ]]; then dump-mem "$@"; fi
