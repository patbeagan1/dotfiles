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
    echo ${machine}
}

if [[ "$1" = "-e" ]]; then shift; machinetype "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
