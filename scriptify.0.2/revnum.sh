revnum () 
{ 
    git rev-list --count HEAD
}

if [[ "$1" = "-e" ]]; then shift; revnum "$@"; fi
