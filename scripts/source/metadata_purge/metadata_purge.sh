#!/bin/bash
# (c) 2022 Pat Beagan: MIT License

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