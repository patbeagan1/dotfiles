kc () 
{ 
    kotlinc "$1" -include-runtime -d out.jar
}
if [[ $0 != "-bash" ]]; then kc "$@"; fi
