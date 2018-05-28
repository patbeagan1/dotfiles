lastlog () 
{ 
    cd /var/log;
    less $(ls -1t | head -1)
}

if [[ "$1" = "-e" ]]; then shift; lastlog "$@"; fi
