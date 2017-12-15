__git_pretty_aliases () 
{ 
    __git_get_config_variables "pretty"
}
if [[ $0 != "-bash" ]]; then __git_pretty_aliases "$@"; fi
