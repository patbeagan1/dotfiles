diffall () 
{ 
    for i in *;
    do
        for j in *;
        do
            echo === $i \|\| $j;
            diff $i $j;
        done;
    done
}
if [[ $0 != "-bash" ]]; then diffall "$@"; fi
