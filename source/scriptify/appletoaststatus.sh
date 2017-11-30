appletoaststatus () 
{ 
    if [ $? -eq 0 ]; then
        appletoast "$0" "Finished!";
    else
        appletoast "$0" "FAILURE";
    fi
}
if [[ $0 != "-bash" ]]; then appletoaststatus "$@"; fi
