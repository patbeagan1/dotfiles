svn () 
{ 
    if [[ "$@" == "add all" ]] || [[ "$@" == "addall" ]]; then
        command svn add $(svn st | grep ? | sed s"/\?//");
    else
        if [[ "$@" == "rm all" ]] || [[ "$@" == "rmall" ]]; then
            command svn rm $(svn st | grep ! | sed s"/\!//");
        else
            if [[ "$@" == "log" ]]; then
                command svn log | less;
            else
                command svn "$@";
            fi;
        fi;
    fi
}

if [[ "$1" = "-e" ]]; then shift; svn "$@"; fi
