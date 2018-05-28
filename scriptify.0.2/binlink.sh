binlink () 
{ 
    ln -s $(pwd)/$1 /usr/local/bin/$1
}

if [[ "$1" = "-e" ]]; then shift; binlink "$@"; fi
