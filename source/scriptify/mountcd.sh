mountcd () 
{ 
    mount /path/to/file.iso /mnt/cdrom -oloop
}
if [[ $0 != "-bash" ]]; then mountcd "$@"; fi
