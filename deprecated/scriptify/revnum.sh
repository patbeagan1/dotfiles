revnum () 
{ 
    git rev-list --count HEAD
}
if [[ $0 != "-bash" ]]; then revnum "$@"; fi
