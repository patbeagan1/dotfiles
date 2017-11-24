realconf () 
{ 
    cat $1 | grep --color=auto --color=auto -v '#' | grep --color=auto --color=auto -v '^$'
}
if [[ $0 != "-bash" ]]; then realconf "$@"; fi
