list-installed () 
{ 
    dpkg-query -Wf '${Installed-size}\t${Package}\n' | column -t | sort -n
}
if [[ $0 != "-bash" ]]; then list-installed "$@"; fi
