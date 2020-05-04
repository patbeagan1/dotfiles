#!/bin/bash

usage()
{
    # routing usage to stderr
    echo "Usage: $0 [-s <45|90>] [-p <string>]" 1>&2; exit 1;
}

usage_variant ()
{
    cat << EOF
    Usage: $0 [-s <45|90>] [-p <string>]
EOF # has to be left aligned
    exit 1
    
}

r () { echo r "$@"; }

p () { echo p "$@"; }

main () {
    
    # showing how to limit the number of arguments
    if [ $# -gt 1 ] ; then
        usage
    fi
    
    # getting options from the terminal
    while getopts ":r:p:" o; do
        case "${o}" in
            r) r "${OPTARG}" || usage
            ;;
            # fail to usage if the function returns anything other than 1
            p) p "${OPTARG}" || usage
            ;;
            *) usage
            ;;
        esac
    done
    shift $((OPTIND-1))
    
    
    # making sure that the variables are filled
    # showing how to handle very long conditionals
    a="x"
    b="x"
    local success=0
    test -z "${a}" && success=1
    test -z "${b}" && success=1
    if ((success)); then
        usage
    fi
    
    # getopts strips out the options, so they do not appear here
    echo total args were "$@"
    
}

main -p foo -s bar x y z
main "$@"
