most_used () 
{ 
    story | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep --color=auto -v "./" | column -c3 -s " " -t | sort -nr | nl | head -n10
}
if [[ $0 != "-bash" ]]; then most_used "$@"; fi
