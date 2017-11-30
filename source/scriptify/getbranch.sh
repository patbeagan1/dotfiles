getbranch () 
{ 
    printf $(git rev-parse --abbrev-ref HEAD)
}
if [[ $0 != "-bash" ]]; then getbranch "$@"; fi
