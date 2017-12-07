show_path () 
{ 
    echo $PATH | sed "s/:/&\n/g"
}
if [[ $0 != "-bash" ]]; then show_path "$@"; fi
