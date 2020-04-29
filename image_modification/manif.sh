manif () 
{ 
    lynx -accept_all_cookies http://tldp.org/LDP/abs/html/comparison-ops.html
}

if [[ "$1" = "-e" ]]; then shift; manif "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
