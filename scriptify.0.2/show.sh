show () 
{ 
    if [ "$1" == "lifecycle" ]; then
        open https://i.stack.imgur.com/1llRw.png;
    fi;
    if [ "$1" == "versions" ]; then
        open https://source.android.com/source/build-numbers#platform-code-names-versions-api-levels-and-ndk-releases;
    fi;
    if [ "$1" == "patterns" ]; then
        open https://i.pinimg.com/736x/5c/33/8e/5c338e86d098eb9955703b00dd3f20ea--programming-patterns-programming-languages.jpg;
    fi;
    if [ "$1" == "cat" ]; then
        open https://static.pexels.com/photos/45201/kitty-cat-kitten-pet-45201.jpeg;
    fi;
    if [ "$1" == "chair" ]; then
        open https://secure.img1-fg.wfcdn.com/im/60980607/resize-h800%5Ecompr-r85/2899/28992811/Chrisanna+Wingback+Chair.jpg;
    fi
}

if [[ "$1" = "-e" ]]; then shift; show "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
