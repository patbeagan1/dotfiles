editlast () 
{ 
    vi $(find . -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" ")
}
if [[ $0 != "-bash" ]]; then editlast "$@"; fi
