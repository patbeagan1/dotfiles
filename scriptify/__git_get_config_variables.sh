__git_get_config_variables () 
{ 
    local section="$1" i IFS='
';
    for i in $(git --git-dir="$(__gitdir)" config --name-only --get-regexp "^$section\..*" 2>/dev/null);
    do
        echo "${i#$section.}";
    done
}
if [[ $0 != "-bash" ]]; then __git_get_config_variables "$@"; fi
