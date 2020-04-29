refresh () 
{ 
    currentDir=$(pwd);
    if [ -f ~/.bash_profile ]; then
        source ~/.bash_profile;
    fi;
    if [ -f ~/.bashrc ]; then
        source ~/.bashrc;
    fi;
    if [ -f ~/.bash_aliases ]; then
        source ~/.bash_aliases;
    fi;
    cd $currentDir
}

if [[ "$1" = "-e" ]]; then shift; refresh "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
