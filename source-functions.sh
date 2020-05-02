parse_git_branch() 
{
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
    git rev-list --count HEAD 2> /dev/null
}

ps_padding() 
{
    echo " $(date +"%H:%M:%S")$(parse_git_branch)" | tr "\n" " "
}

release () 
{ 
    echo release-v4."$1"; 
}

curr () 
{
    git fetch && git branch -a | grep release-v | sed 's/remotes\/origin\///g' | sort | tail -1 | sed 's/\*//g'
}

last_branch()
{ 
    git branch --sort=committerdate;
}

lsfuncs () 
{ 
    echo $(set | grep \(\) | grep -v =) | sed s/\(\)//g | sed s/\ \ /\ /g
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
            type "$1" | tail -n +2 | tee "$1".sh && chmod 755 "$1".sh;
            echo >> "$1".sh
            echo "$1" '"$@"' >> "$1".sh

            # Optionally, this code will make the function executable if the -e flag is passed into it.
            # -----
            # echo "if [[ \"\$1\" = \"-e\" ]]; then shift; $1 \"\$@\"; fi" >> "$1".sh;
            # echo 'usage () { echo Print this usage text.; }' >> "$1".sh;
            # echo "if [[ \"\$1\" = \"-h\" ]]; then printf \"Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t"'$(usage)'"\n\" \"\$0\"; fi" >> "$1".sh;
        fi;
    fi
}

