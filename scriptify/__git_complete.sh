__git_complete () 
{ 
    local wrapper="__git_wrap${2}";
    eval "$wrapper () { __git_func_wrap $2 ; }";
    complete -o bashdefault -o default -o nospace -F $wrapper $1 2> /dev/null || complete -o default -o nospace -F $wrapper $1
}
if [[ $0 != "-bash" ]]; then __git_complete "$@"; fi
