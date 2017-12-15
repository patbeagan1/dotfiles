__git_find_on_cmdline () 
{ 
    local word subcommand c=1;
    while [ $c -lt $cword ]; do
        word="${words[c]}";
        for subcommand in $1;
        do
            if [ "$subcommand" = "$word" ]; then
                echo "$subcommand";
                return;
            fi;
        done;
        ((c++));
    done
}
if [[ $0 != "-bash" ]]; then __git_find_on_cmdline "$@"; fi
