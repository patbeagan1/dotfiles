destroy_dsstore_local () 
{ 
    find . -name .DS_Store -exec drop {} \;
}
if [[ $0 != "-bash" ]]; then destroy_dsstore_local "$@"; fi
