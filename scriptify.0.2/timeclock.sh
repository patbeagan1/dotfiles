timeclock () 
{ 
    printf "%s\t|%s\n" "$1" "`date`" >> ~/timeclock.log
}

if [[ "$1" = "-e" ]]; then shift; timeclock "$@"; fi
