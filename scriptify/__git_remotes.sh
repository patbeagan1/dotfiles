__git_remotes () 
{ 
    local d="$(__gitdir)";
    test -d "$d/remotes" && ls -1 "$d/remotes";
    git --git-dir="$d" remote
}
if [[ $0 != "-bash" ]]; then __git_remotes "$@"; fi
