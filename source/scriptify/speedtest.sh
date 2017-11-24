speedtest () 
{ 
    dd if=/dev/zero of=/dev/null bs=1M count=32768
}
if [[ $0 != "-bash" ]]; then speedtest "$@"; fi
