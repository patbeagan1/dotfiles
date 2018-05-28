editlast () 
{ 
    vi $(find . -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" ")
}

if [[ "$1" = "-e" ]]; then shift; editlast "$@"; fi
