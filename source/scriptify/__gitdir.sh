__gitdir () 
{ 
    if [ -z "${1-}" ]; then
        if [ -n "${__git_dir-}" ]; then
            echo "$__git_dir";
        else
            if [ -n "${GIT_DIR-}" ]; then
                test -d "${GIT_DIR-}" || return 1;
                echo "$GIT_DIR";
            else
                if [ -d .git ]; then
                    echo .git;
                else
                    git rev-parse --git-dir 2> /dev/null;
                fi;
            fi;
        fi;
    else
        if [ -d "$1/.git" ]; then
            echo "$1/.git";
        else
            echo "$1";
        fi;
    fi
}
if [[ $0 != "-bash" ]]; then __gitdir "$@"; fi
