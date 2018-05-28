manbook () 
{ 
    cat $1 | groff -man -Tps > book.ps
}

if [[ "$1" = "-e" ]]; then shift; manbook "$@"; fi
