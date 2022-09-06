#!/bin/bash

dot2pdf () 
{ 
    dot -Tpdf "$1" > "$1".pdf && open "$1".pdf
}

dot2pdf "$@"
trackusage.sh "$0"