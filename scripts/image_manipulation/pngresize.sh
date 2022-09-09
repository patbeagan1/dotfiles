#!/bin/bash

pngresize () 
{ 
    convert -verbose -resize "$2"% -quality 100 "$1" "$1"."$3".png
}

pngresize "$@"
trackusage.sh "$0"