comic () 
{ 
    zip -r $1.zip $1;
    mv $1.zip $1.cbz
}
if [[ $0 != "-bash" ]]; then comic "$@"; fi
