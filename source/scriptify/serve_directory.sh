serve_directory () 
{ 
    python -m SimpleHTTPServer
}
if [[ $0 != "-bash" ]]; then serve_directory "$@"; fi
