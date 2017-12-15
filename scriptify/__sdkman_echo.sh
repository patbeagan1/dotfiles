__sdkman_echo () 
{ 
    if [[ "$sdkman_colour_enable" == 'false' ]]; then
        echo -e "$2";
    else
        echo -e "\033[1;$1$2\033[0m";
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_echo "$@"; fi
