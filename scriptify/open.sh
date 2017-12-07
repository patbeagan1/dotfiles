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
if [[ $0 != "-bash" ]]; then open "$@"; fi
