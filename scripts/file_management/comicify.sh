#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

comicify ()
{
    comic ()
    {
        name=$(echo "$1" | sed 's/\///g')
        zip -r "$name".zip "$name";
        mv "$name".zip "$name".cbz
    }

    for i in $(ls | grep -v .cbz);
    do
        match='false';
        for j in $(ls | grep .cbz);
        do
            if [[ "$j" =~ "$i" ]]; then
                match='true';
                break;
            fi;
        done;
        if [ $match = 'true' ]; then
            echo 'comicified   '"$i";
        else
            [[ -d NOZIP ]] || mkdir NOZIP
            if [ "$i" != "NOZIP" ]; then
                echo 'comic create '"$i";
                mv "$i"/*.webm NOZIP
                comic "$i";
            fi
        fi;
    done
}
comicify
trackusage.sh "$0"
