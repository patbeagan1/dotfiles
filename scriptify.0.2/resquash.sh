resquash () 
{ 
    function getbranch () 
    { 
        printf $(git rev-parse --abbrev-ref HEAD)
    };
    function reset_origin () 
    { 
        was_last_reset_successful="false";
        echo This is a hard reset.;
        read -p "Are you sure you want to check out origin/$(getbranch)? " -n 1 -r;
        echo;
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git fetch && git reset --hard origin/$(getbranch);
            was_last_reset_successful="true";
        fi
    };
    function get_longest_matching_branch () 
    { 
        git for-each-ref --shell --format='%(refname)' refs/heads/ | grep --color=auto --color=auto "${1}" | awk '{print length, $0}' | sort -nr | head -1 | cut -d" " -f2 | sed 's/.*\///' | tr "'" " " | tr -d " "
    };
    function perform_squash () 
    { 
        git branch -m "$b";
        git checkout "$1";
        if [ "$(getbranch)" = "$1" ]; then
            printf "Reset base branch with its origin first?";
            read;
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                reset_origin;
            else
                was_last_reset_successful="true";
            fi;
            if [ "$was_last_reset_successful" = "true" ]; then
                git checkout -b "$a";
                git merge --squash "$b";
            fi;
            echo "The previous commits were:";
            echo "$previous_commit";
        else
            echo Failed to check out new branch.;
            printf "Should I rename the branch?\\n%s -> %s\\n" "$(getbranch)" "$a";
            read;
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                git branch -m "$a";
            fi;
        fi
    };
    if [ $# -ne 1 ]; then
        echo "You must supply the base branch as an argument.";
        echo "Usage: resquash <base_branch>";
    else
        a="$(getbranch)";
        b="$(get_longest_matching_branch "${a}")_old";
        previous_commit="$(git log -2)";
        printf "%s -> %s\\n" "$a" "$b";
        read -p "Is the above backup branch named correctly?" -n 1 -r;
        echo;
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            perform_squash "$1";
        fi;
    fi
}

if [[ "$1" = "-e" ]]; then shift; resquash "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
