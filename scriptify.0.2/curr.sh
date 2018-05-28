curr () 
{ 
    git fetch && git branch -a | grep --color=auto release-v | sed 's/remotes\/origin\///g' | sort | tail -1 | sed 's/\*//g'
}

if [[ "$1" = "-e" ]]; then shift; curr "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
