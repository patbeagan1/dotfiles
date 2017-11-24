lsfuncs () 
{ 
    echo $(set | grep \(\) | grep -v =) | sed s/\(\)//g | sed s/\ \ /\ /g
}
if [[ $0 != "-bash" ]]; then lsfuncs "$@"; fi
