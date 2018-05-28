manbash () 
{ 
    man -P "less '+/^ *'${1}" bash
}
if [[ $0 != "-bash" ]]; then manbash "$@"; fi
