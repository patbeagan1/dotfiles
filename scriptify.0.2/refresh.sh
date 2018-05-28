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
