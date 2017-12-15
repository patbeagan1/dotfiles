gitfile () 
{ 
    git status --porcelain | sed s/^...//
}
if [[ $0 != "-bash" ]]; then gitfile "$@"; fi
