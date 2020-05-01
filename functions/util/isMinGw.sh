isMinGw () 
{ 
    if [ "MinGw" = $(machinetype) ]; then
        return 0;
    else
        return 1;
    fi
}
