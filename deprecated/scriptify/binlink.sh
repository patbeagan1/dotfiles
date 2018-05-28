binlink () 
{ 
    ln -s $(pwd)/$1 /usr/local/bin/$1
}
if [[ $0 != "-bash" ]]; then binlink "$@"; fi
