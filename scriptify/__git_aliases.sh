__git_aliases () 
{ 
    __git_get_config_variables "alias"
}
if [[ $0 != "-bash" ]]; then __git_aliases "$@"; fi
