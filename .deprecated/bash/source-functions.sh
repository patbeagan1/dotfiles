
lsfuncs ()
{
    local a=`echo $(set | grep \(\) | grep -v =) | sed s/\(\)//g | sed s/\ \ /\ /g`
    multiline.sh "$a"
}

history_me ()
{
    history |\
    awk '{CMD[$4]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' |\
    grep -v "./" |\
    column -c3 -s " " -t |\
    sort -nr |\
    nl |\
    head -n10;
}

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

scriptify ()
{
    if [[ "$(type "$1")" == *"is a shell builtin" ]]; then
        echo This is a shell builtin.;
    else
        if [[ "$(type "$1")" == *"is aliased to"* ]]; then
            echo This is an alias.;
        else
            # Printing out the contents of the function to a file and making it executable
            echo '#!/bin/bash' >> "$1".sh &&
            if test $?; then
                chmod 755 "$1".sh;
                cat << EOF >> "$1".sh

set -euo pipefail
IFS=$'\n\t'

EOF
                type "$1" | tail -n +2 | cat
                type "$1" | tail -n +2 >> "$1".sh
                echo >> "$1".sh
                echo "$1" '"$@"' >> "$1".sh
            fi
            # Optionally, this code will make the function executable if the -e flag is passed into it.
            # -----
            # echo "if [[ \"\$1\" = \"-e\" ]]; then shift; $1 \"\$@\"; fi" >> "$1".sh;
            # echo 'usage () { echo Print this usage text.; }' >> "$1".sh;
            # echo "if [[ \"\$1\" = \"-h\" ]]; then printf \"Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t"'$(usage)'"\n\" \"\$0\"; fi" >> "$1".sh;
        fi;
    fi
}

