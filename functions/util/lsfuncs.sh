lsfuncs () 
{ 
    echo $(set | grep \(\) | grep -v =) | sed s/\(\)//g | sed s/\ \ /\ /g
}
