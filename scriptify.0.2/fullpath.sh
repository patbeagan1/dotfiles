fullpath () 
{ 
    case "$1" in 
        /*)
            printf '%s\n' "$1"
        ;;
        *)
            printf '%s\n' "$PWD/$1"
        ;;
    esac
}

if [[ "$1" = "-e" ]]; then shift; fullpath "$@"; fi
