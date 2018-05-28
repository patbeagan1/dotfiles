pause () 
{ 
    read -p "$*"
}
if [[ $0 != "-bash" ]]; then pause "$@"; fi
