tocamelcase () 
{ 
    echo "$1" | perl -pe 's/(^|_)./uc($&)/ge;s/_//g'
}

if [[ "$1" = "-e" ]]; then shift; tocamelcase "$@"; fi
