__git_get_option_value () 
{ 
    local c short_opt long_opt val;
    local result= values config_key word;
    short_opt="$1";
    long_opt="$2";
    values="$3";
    config_key="$4";
    ((c = $cword - 1));
    while [ $c -ge 0 ]; do
        word="${words[c]}";
        for val in $values;
        do
            if [ "$short_opt$val" = "$word" ] || [ "$long_opt$val" = "$word" ]; then
                result="$val";
                break 2;
            fi;
        done;
        ((c--));
    done;
    if [ -n "$config_key" ] && [ -z "$result" ]; then
        result="$(git --git-dir="$(__gitdir)" config "$config_key")";
    fi;
    echo "$result"
}
if [[ $0 != "-bash" ]]; then __git_get_option_value "$@"; fi
