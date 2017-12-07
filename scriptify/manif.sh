manif () 
{ 
    lynx -accept_all_cookies http://tldp.org/LDP/abs/html/comparison-ops.html
}
if [[ $0 != "-bash" ]]; then manif "$@"; fi
