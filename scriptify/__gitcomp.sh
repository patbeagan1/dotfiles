__gitcomp () 
{ 
    local cur_="${3-$cur}";
    case "$cur_" in 
        --*=)

        ;;
        *)
            local c i=0 IFS=' 	
';
            for c in $1;
            do
                c="$c${4-}";
                if [[ $c == "$cur_"* ]]; then
                    case $c in 
                        --*=* | *.)

                        ;;
                        *)
                            c="$c "
                        ;;
                    esac;
                    COMPREPLY[i++]="${2-}$c";
                fi;
            done
        ;;
    esac
}
if [[ $0 != "-bash" ]]; then __gitcomp "$@"; fi
