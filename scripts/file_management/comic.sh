#!/bin/bash 

comic () 
{ 
    zip -r $1.zip $1;
    mv $1.zip $1.cbz
}
comic "$@"

trackusage.sh "$0"