__git_config_get_set_variables () 
{ 
    local prevword word config_file= c=$cword;
    while [ $c -gt 1 ]; do
        word="${words[c]}";
        case "$word" in 
            --system | --global | --local | --file=*)
                config_file="$word";
                break
            ;;
            -f | --file)
                config_file="$word $prevword";
                break
            ;;
        esac;
        prevword=$word;
        c=$((--c));
    done;
    git --git-dir="$(__gitdir)" config $config_file --name-only --list 2> /dev/null
}
if [[ $0 != "-bash" ]]; then __git_config_get_set_variables "$@"; fi
