resquash_old () 
{ 
    function get_longest_matching_branch () 
    { 
        echo "$(git branch | grep $(getbranch) |  awk '{ print length($0) " " $0; }' $file | sort -r -n | cut -d ' ' -f 2- | head -1 )" | sed 's/[[:blank:]]//g' | sed 's/*//g'
    };
    if [ $# -ne 1 ]; then
        echo "You must supply the base branch as an argument.";
        echo "Usage: resquash <base_branch>";
    else
        a="$(getbranch)";
        b="$(get_longest_matching_branch)_old";
        printf "%s -> %s\n" "$a" "$b";
        git branch -m "$b";
        git co "$1";
        reset_origin;
        git co -b "$a";
        git merge --squash "$b";
    fi
}
if [[ $0 != "-bash" ]]; then resquash_old "$@"; fi
