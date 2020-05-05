#!/bin/bash

pdf2png () 
{ 
    convert -verbose -density 400 -trim "$1" -quality 100 -flatten -sharpen 0x1.0 "$1".png
}

pdf2png "$@"
