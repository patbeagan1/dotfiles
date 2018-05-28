jj () 
{ 
    javac ${1};
    java $(echo ${1} | sed s/\.java// )
}
if [[ $0 != "-bash" ]]; then jj "$@"; fi
