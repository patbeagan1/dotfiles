wiki () 
{ 
    lynx -accept_all_cookies -accept_all_cookies http://en.wikipedia.org/wiki/Special:Search?search=$(echo $@ | sed 's/ /+/g')
}

if [[ "$1" = "-e" ]]; then shift; wiki "$@"; fi
