flatten () 
{ 
    mkdir flattened_files && find . -exec cp -n $(echo '{}') flattened_files \;
}
if [[ $0 != "-bash" ]]; then flatten "$@"; fi
