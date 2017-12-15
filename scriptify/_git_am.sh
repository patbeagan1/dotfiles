_git_am () 
{ 
    local dir="$(__gitdir)";
    if [ -d "$dir"/rebase-apply ]; then
        __gitcomp "--skip --continue --resolved --abort";
        return;
    fi;
    case "$cur" in 
        --whitespace=*)
            __gitcomp "$__git_whitespacelist" "" "${cur##--whitespace=}";
            return
        ;;
        --*)
            __gitcomp "
			--3way --committer-date-is-author-date --ignore-date
			--ignore-whitespace --ignore-space-change
			--interactive --keep --no-utf8 --signoff --utf8
			--whitespace= --scissors
			";
            return
        ;;
    esac
}
if [[ $0 != "-bash" ]]; then _git_am "$@"; fi
