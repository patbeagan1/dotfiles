wiki () 
{ 
    lynx -accept_all_cookies -accept_all_cookies http://en.wikipedia.org/wiki/Special:Search?search=$(echo $@ | sed 's/ /+/g')
}

if [[ "$1" = "-e" ]]; then shift; wiki "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
