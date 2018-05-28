comic () 
{ 
    zip -r $1.zip $1;
    mv $1.zip $1.cbz
}

if [[ "$1" = "-e" ]]; then shift; comic "$@"; fi
