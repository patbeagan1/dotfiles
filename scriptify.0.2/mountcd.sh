mountcd () 
{ 
    mount /path/to/file.iso /mnt/cdrom -oloop
}

if [[ "$1" = "-e" ]]; then shift; mountcd "$@"; fi
