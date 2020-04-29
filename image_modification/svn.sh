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
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
