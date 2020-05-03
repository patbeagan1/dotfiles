
lsfuncs ()
{
    local a=`echo $(set | grep \(\) | grep -v =) | sed s/\(\)//g | sed s/\ \ /\ /g`
    multiline.sh "$a"
}

appletoaststatus () 
{ 
    if [ $? -eq 0 ]; then
        appletoast.sh "$0" "Finished!";
    else
        appletoast.sh "$0" "FAILURE";
    fi
}

check_return ()
{
    local a=$?;
    echo $a;
    return $a
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
                echo >> "$1".sh
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

function extract {
    # function Extract for common file formats
    # https://github.com/xvoland/Extract
    
    SAVEIFS=$IFS
    IFS="$(printf '\n\t')"
    if [ -z "$1" ]; then
        # display usage if no parameters given
        echo "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>"
        echo "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]"
    else
        for n in "$@"
        do
            if [ -f "$n" ] ; then
                case "${n%,}" in
                    *.lzma)
                        unlzma ./"$n"
                    ;;
                    *.cbt|*.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar)
                        tar xvf "$n"
                    ;;
                    *.bz2)
                        bunzip2 ./"$n"
                    ;;
                    *.cbr|*.rar)
                        unrar x -ad ./"$n"
                    ;;
                    *.gz)
                        gunzip ./"$n"
                    ;;
                    *.cbz|*.epub|*.zip)
                        unzip ./"$n"
                    ;;
                    *.z)
                        uncompress ./"$n"
                    ;;
                    *.7z|*.apk|*.arj|*.cab|*.cb7|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.pkg|*.rpm|*.udf|*.wim|*.xar)
                        7z x ./"$n"
                    ;;
                    *.xz)
                        unxz ./"$n"
                    ;;
                    *.exe)
                        cabextract ./"$n"
                    ;;
                    *.cpio)
                        cpio -id < ./"$n"
                    ;;
                    *.cba|*.ace)
                        unace x ./"$n"
                    ;;
                    *.zpaq)
                        zpaq x ./"$n"
                    ;;
                    *.arc)
                        arc e ./"$n"
                    ;;
                    *.cso)
                        ciso 0 ./"$n" ./"$n.iso" && \
                        extract $n.iso && \rm -f $n
                    ;;
                    *)
                        echo "extract: '$n' - unknown archive method"
                        return 1
                    ;;
                esac
            else
                echo "'$n' - file does not exist"
                return 1
            fi
        done
    fi
    IFS=$SAVEIFS
}

if [ ${#} -eq 0 ]  
then 
true 
else 
exit 1 # wrong args 
fi 

