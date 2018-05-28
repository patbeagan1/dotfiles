kc () 
{ 
    kotlinc "$1" -include-runtime -d out.jar
}

if [[ "$1" = "-e" ]]; then shift; kc "$@"; fi
