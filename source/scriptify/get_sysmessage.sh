get_sysmessage () 
{ 
    if [ -z $Category ]; then
        Category="Undefined";
    fi;
    echo "
    Category: $Category
    Machine:  $(hostname)
    Script:   $0
    Date:     $(date)
    "
}
if [[ $0 != "-bash" ]]; then get_sysmessage "$@"; fi
