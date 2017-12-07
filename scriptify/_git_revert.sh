_git_revert () 
{ 
    local dir="$(__gitdir)";
    if [ -f "$dir"/REVERT_HEAD ]; then
        __gitcomp "--continue --quit --abort";
        return;
    fi;
    case "$cur" in 
        --*)
            __gitcomp "--edit --mainline --no-edit --no-commit --signoff";
            return
        ;;
    esac;
    __gitcomp_nl "$(__git_refs)"
}
if [[ $0 != "-bash" ]]; then _git_revert "$@"; fi
