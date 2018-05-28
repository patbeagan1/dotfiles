flatten () 
{ 
    mkdir flattened_files && find . -exec cp -n $(echo '{}') flattened_files \;
}

if [[ "$1" = "-e" ]]; then shift; flatten "$@"; fi
