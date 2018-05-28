appletoaststatus () 
{ 
    if [ $? -eq 0 ]; then
        appletoast "$0" "Finished!";
    else
        appletoast "$0" "FAILURE";
    fi
}

if [[ "$1" = "-e" ]]; then shift; appletoaststatus "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
