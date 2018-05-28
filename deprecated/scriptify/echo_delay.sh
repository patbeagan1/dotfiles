echo_delay () 
{ 
    shift;
    echo "$@" | pv -qL 10
}
if [[ $0 != "-bash" ]]; then echo_delay "$@"; fi
