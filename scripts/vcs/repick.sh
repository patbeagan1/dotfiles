#!/bin/bash 

repick () 
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
        echo "$(git branch | grep $(getbranch) |  awk '{ print length($0) " " $0; }' $file | sort -r -n | cut -d ' ' -f 2- | head -1 )" | sed 's/[[:blank:]]//g' | sed 's/*//g'
    };
    if [ $# -ne 2 ]; then
        echo "You must supply the base branch as an argument.";
        echo "Usage: resquash <base_branch> <base_commit>";
    else
        a="$(getbranch)";
        b="$(get_longest_matching_branch)_old";
        c="$($2)";
        printf "%s -> %s\\n" "$a" "$b";
        read -p "Is the above backup branch named correctly?" -n 1 -r;
        echo;
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git branch -m "$b";
            git co "$1";
            if [ "$(getbranch)" = "$1" ]; then
                reset_origin;
                if [ "$was_last_reset_successful" = "true" ]; then
                    git co -b "$a";
                    echo git cherry-pick "$(git rev-parse $c)".."$(git rev-parse $b)";
                    read -p "Continue with cherry pick?" -n 1 -r;
                    if [[ $REPLY =~ ^[Yy]$ ]]; then
                        git cherry-pick "$(git rev-parse $c)".."$(git rev-parse $b)";
                    fi;
                fi;
            fi;
        fi;
    fi
}
repick "$@"
