timeclock () 
{ 
    printf "%s\t|%s\n" "$1" "`date`" >> ~/timeclock.log
}
if [[ $0 != "-bash" ]]; then timeclock "$@"; fi
