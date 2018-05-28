__git_refs_remotes () 
{ 
    local i hash;
    git ls-remote "$1" 'refs/heads/*' 2> /dev/null | while read -r hash i; do
        echo "$i:refs/remotes/$1/${i#refs/heads/}";
    done
}
if [[ $0 != "-bash" ]]; then __git_refs_remotes "$@"; fi
