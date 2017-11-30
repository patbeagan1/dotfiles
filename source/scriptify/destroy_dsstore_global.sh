destroy_dsstore_global () 
{ 
    sudo find / -name ".DS_Store" -depth -exec echo {} \;
}
if [[ $0 != "-bash" ]]; then destroy_dsstore_global "$@"; fi
