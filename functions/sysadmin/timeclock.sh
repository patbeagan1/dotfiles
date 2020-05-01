timeclock () 
{ 
    printf "%s\t|%s\n" "$1" "`date`" >> ~/timeclock.log
}
