lastlog () 
{ 
    cd /var/log;
    less $(ls -1t | head -1)
}
if [[ $0 != "-bash" ]]; then lastlog "$@"; fi
