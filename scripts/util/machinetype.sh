#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

machinetype () 
{ 
    unameOut="$(uname -s)";
    case "${unameOut}" in 
        Linux*)
            machine=Linux
        ;;
        Darwin*)
            machine=Mac
        ;;
        CYGWIN*)
            machine=Cygwin
        ;;
        MINGW*)
            machine=MinGw
        ;;
        *)
            machine="UNKNOWN:${unameOut}"
        ;;
    esac;
    echo -n ${machine}
}

machinetype "$@"
trackusage.sh "$0"