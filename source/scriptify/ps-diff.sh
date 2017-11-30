ps-diff () 
{ 
    diff <(lsof -p $1) <(sleep 10; lsof -p $1)
}
if [[ $0 != "-bash" ]]; then ps-diff "$@"; fi
