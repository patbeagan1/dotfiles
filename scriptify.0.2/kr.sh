kr () 
{ 
    java -jar "$1"
}

if [[ "$1" = "-e" ]]; then shift; kr "$@"; fi
