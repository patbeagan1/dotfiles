mean_missing () 
{ 
    count=$(count_list "$1");
    math "$(math "$3"-$(mean "$1" $count))*$count"
}
if [[ $0 != "-bash" ]]; then mean_missing "$@"; fi
