#!/bin/bash 

fix_script () 
{ 
    for i in *.sh;
    do
        echo >> $i;
        echo $(echo $i | cut -d'.' -f1) '"$@"' >> $i;
    done
}

fix_script "$@"
trackusage.sh "$0"