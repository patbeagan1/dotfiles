__git_index_files () 
{ 
    local dir="$(__gitdir)" root="${2-.}" file;
    if [ -d "$dir" ]; then
        __git_ls_files_helper "$root" "$1" | while read -r file; do
            case "$file" in 
                ?*/*)
                    echo "${file%%/*}"
                ;;
                *)
                    echo "$file"
                ;;
            esac;
        done | sort | uniq;
    fi
}
if [[ $0 != "-bash" ]]; then __git_index_files "$@"; fi
