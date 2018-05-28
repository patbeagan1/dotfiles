jj () 
{ 
    javac ${1};
    java $(echo ${1} | sed s/\.java// )
}

if [[ "$1" = "-e" ]]; then shift; jj "$@"; fi
