track-logs () 
{ 
    tail -f $(for i in `file /var/log/* | grep text | sed s/:.*$//`; do echo $i; done)
}
if [[ $0 != "-bash" ]]; then track-logs "$@"; fi
