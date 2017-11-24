rec () 
{ 
    script ~/Downloads/typescript-`date | sed 's/ /-/g'`.log;
    history > ~/Downloads/"$(echo "history-`date`.log" | sed s/\ /_/g)"
}
if [[ $0 != "-bash" ]]; then rec "$@"; fi
