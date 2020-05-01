manbook () 
{ 
    cat $1 | groff -man -Tps > book.ps
}
