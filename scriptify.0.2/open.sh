open () 
{ 
    if [ "$(uname)" == "Linux" ]; then
        gnome-open "$@";
    else
        if [ "$(uname)" == "Darwin" ]; then
            command open "$@";
        else
            echo "This command is not supported.";
        fi;
    fi
}

if [[ "$1" = "-e" ]]; then shift; open "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
