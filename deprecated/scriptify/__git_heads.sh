__git_heads () 
{ 
    local dir="$(__gitdir)";
    if [ -d "$dir" ]; then
        git --git-dir="$dir" for-each-ref --format='%(refname:short)' refs/heads;
        return;
    fi
}
if [[ $0 != "-bash" ]]; then __git_heads "$@"; fi
