#!/bin/bash

metadata_purge () 
{ 
    for i in *.jpg;
    do
        echo "Processing $i";
        exiftool -all= "$i";
    done
}

metatdata_purge "$@"
trackusage.sh "$0"