show-matrix () 
{ 
    echo -e "\e[32m";
    while :; do
        for i in {1..16};
        do
            r="$(($RANDOM % 2))";
            if [[ $(($RANDOM % 5)) == 1 ]]; then
                if [[ $(($RANDOM % 4)) == 1 ]]; then
                    v+="\e[1m $r   ";
                else
                    v+="\e[2m $r   ";
                fi;
            else
                v+="     ";
            fi;
        done;
        echo -e "$v";
        v="";
    done
}
if [[ $0 != "-bash" ]]; then show-matrix "$@"; fi
