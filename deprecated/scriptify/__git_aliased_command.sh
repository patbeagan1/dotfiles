__git_aliased_command () 
{ 
    local word cmdline=$(git --git-dir="$(__gitdir)" 		config --get "alias.$1");
    for word in $cmdline;
    do
        case "$word" in 
            \!gitk | gitk)
                echo "gitk";
                return
            ;;
            \!*)
                : shell command alias
            ;;
            -*)
                : option
            ;;
            *=*)
                : setting env
            ;;
            git)
                : git itself
            ;;
            \(\))
                : skip parens of shell function definition
            ;;
            {)
                : skip start of shell helper function
            ;;
            :)
                : skip null command
            ;;
            \'*)
                : skip opening quote after sh -c
            ;;
            *)
                echo "$word";
                return
            ;;
        esac;
    done
}
if [[ $0 != "-bash" ]]; then __git_aliased_command "$@"; fi
