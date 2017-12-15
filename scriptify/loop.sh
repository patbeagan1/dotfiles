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
if [[ $0 != "-bash" ]]; then loop "$@"; fi
