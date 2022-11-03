#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

comic () 
{ 
    zip -r $1.zip $1;
    mv $1.zip $1.cbz
}
comic "$@"

trackusage.sh "$0"