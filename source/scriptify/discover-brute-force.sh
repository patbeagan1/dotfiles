discover-brute-force () 
{ 
    sudo zcat /var/log/auth.log.*.gz | awk '/Failed password/&&!/for invalid user/{a[$9]++}/Failed password for invalid user/{a["*" $11]++}END{for (i in a) printf "%6s\t%s\n", a[i], i|"sort -n"}'
}
if [[ $0 != "-bash" ]]; then discover-brute-force "$@"; fi
