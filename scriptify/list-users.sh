list-users () 
{ 
    cut -d: -f1 /etc/passwd
}
if [[ $0 != "-bash" ]]; then list-users "$@"; fi
