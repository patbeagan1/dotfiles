__git_match_ctag () 
{ 
    awk "/^${1//\//\\/}/ { print \$1 }" "$2"
}
if [[ $0 != "-bash" ]]; then __git_match_ctag "$@"; fi
