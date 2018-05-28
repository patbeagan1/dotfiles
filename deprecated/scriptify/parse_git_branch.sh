parse_git_branch () 
{ 
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/';
    git rev-list --count HEAD 2> /dev/null
}
if [[ $0 != "-bash" ]]; then parse_git_branch "$@"; fi
