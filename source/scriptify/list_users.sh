list_users () 
{ 
    cut -d: -f1 /etc/passwd
}
if [[ $0 != "-bash" ]]; then list_users "$@"; fi
