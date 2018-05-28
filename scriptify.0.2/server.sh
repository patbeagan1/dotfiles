server () 
{ 
    if [ $# -lt 2 ]; then
        port="$1";
        if [ -z "$port" ]; then
            port="8000";
        fi;
        echo Running server on "$port";
        python -m SimpleHTTPServer "$port";
    else
        echo Too many arguments.;
    fi
}

if [[ "$1" = "-e" ]]; then shift; server "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
