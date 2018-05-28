tp () 
{ 
    PS1='\[\e]0;\w\a\]\n\[\e[00;33m\][\d \A \[\e[01;35m\]\w\[\e[00;33m\]]\[\e[0m\]$(__git_ps1 " \[\033[1;32m\](%s)\[\033[0m\]") $(__awsenv_ps1)\n\$ '
}

if [[ "$1" = "-e" ]]; then shift; tp "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
