#!/bin/bash
# (c) 2022 Pat Beagan: MIT License

dot2pdf () 
{ 
    dot -Tpdf "$1" > "$1".pdf && open "$1".pdf
}

dot2pdf "$@"
trackusage.sh "$0"