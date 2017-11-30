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
    fi
}
if [[ $0 != "-bash" ]]; then show "$@"; fi
