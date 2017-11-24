_git_rebase () 
{ 
    local dir="$(__gitdir)";
    if [ -f "$dir"/rebase-merge/interactive ]; then
        __gitcomp "--continue --skip --abort --edit-todo";
        return;
    else
        if [ -d "$dir"/rebase-apply ] || [ -d "$dir"/rebase-merge ]; then
            __gitcomp "--continue --skip --abort";
            return;
        fi;
    fi;
    __git_complete_strategy && return;
    case "$cur" in 
        --whitespace=*)
            __gitcomp "$__git_whitespacelist" "" "${cur##--whitespace=}";
            return
        ;;
        --*)
            __gitcomp "
			--onto --merge --strategy --interactive
			--preserve-merges --stat --no-stat
			--committer-date-is-author-date --ignore-date
			--ignore-whitespace --whitespace=
			--autosquash --no-autosquash
			--fork-point --no-fork-point
			--autostash --no-autostash
			--verify --no-verify
			--keep-empty --root --force-rebase --no-ff
			--exec
			";
            return
        ;;
    esac;
    __gitcomp_nl "$(__git_refs)"
}
if [[ $0 != "-bash" ]]; then _git_rebase "$@"; fi
