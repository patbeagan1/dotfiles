__git_list_merge_strategies () 
{ 
    git merge -s help 2>&1 | sed -n -e '/[Aa]vailable strategies are: /,/^$/{
		s/\.$//
		s/.*://
		s/^[ 	]*//
		s/[ 	]*$//
		p
	}'
}
if [[ $0 != "-bash" ]]; then __git_list_merge_strategies "$@"; fi
