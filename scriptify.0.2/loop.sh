loop () 
{ 
    while :; do
        $*;
        sleep 0.5;
        if [ $1 == "-c" ]; then
            clear;
        fi;
    done
}

if [[ "$1" = "-e" ]]; then shift; loop "$@"; fi
