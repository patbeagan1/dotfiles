std_deviation () 
{ 
    math "sqrt ($(variance $1))"
}
if [[ $0 != "-bash" ]]; then std_deviation "$@"; fi
