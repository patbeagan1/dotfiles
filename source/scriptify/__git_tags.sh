__git_tags () 
{ 
    local dir="$(__gitdir)";
    if [ -d "$dir" ]; then
        git --git-dir="$dir" for-each-ref --format='%(refname:short)' refs/tags;
        return;
    fi
}
if [[ $0 != "-bash" ]]; then __git_tags "$@"; fi
