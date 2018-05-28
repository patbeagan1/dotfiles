manif () 
{ 
    lynx -accept_all_cookies http://tldp.org/LDP/abs/html/comparison-ops.html
}

if [[ "$1" = "-e" ]]; then shift; manif "$@"; fi
