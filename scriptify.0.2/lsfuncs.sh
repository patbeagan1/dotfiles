lsfuncs () 
{ 
    echo $(set | grep \(\) | grep -v =) | sed s/\(\)//g | sed s/\ \ /\ /g
}

if [[ "$1" = "-e" ]]; then shift; lsfuncs "$@"; fi
