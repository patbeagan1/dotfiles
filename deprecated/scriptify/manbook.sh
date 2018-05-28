manbook () 
{ 
    cat $1 | groff -man -Tps > book.ps
}
if [[ $0 != "-bash" ]]; then manbook "$@"; fi
