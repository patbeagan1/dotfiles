get-youtube-audio () 
{ 
    youtube-dl -t --extract-audio --audio-format mp3 $1
}
if [[ $0 != "-bash" ]]; then get-youtube-audio "$@"; fi
