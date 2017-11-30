__git_commands () 
{ 
    if test -n "${GIT_TESTING_COMMAND_COMPLETION:-}"; then
        printf "%s" "${GIT_TESTING_COMMAND_COMPLETION}";
    else
        git help -a | egrep --color=auto '^  [a-zA-Z0-9]';
    fi
}
if [[ $0 != "-bash" ]]; then __git_commands "$@"; fi
