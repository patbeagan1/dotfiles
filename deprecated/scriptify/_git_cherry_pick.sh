_git_cherry_pick () 
{ 
    local dir="$(__gitdir)";
    if [ -f "$dir"/CHERRY_PICK_HEAD ]; then
        __gitcomp "--continue --quit --abort";
        return;
    fi;
    case "$cur" in 
        --*)
            __gitcomp "--edit --no-commit --signoff --strategy= --mainline"
        ;;
        *)
            __gitcomp_nl "$(__git_refs)"
        ;;
    esac
}
if [[ $0 != "-bash" ]]; then _git_cherry_pick "$@"; fi
