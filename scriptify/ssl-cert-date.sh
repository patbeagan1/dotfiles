ssl-cert-date () 
{ 
    echo | openssl s_client -connect $1:443 2> /dev/null | openssl x509 -dates -noout
}
if [[ $0 != "-bash" ]]; then ssl-cert-date "$@"; fi
