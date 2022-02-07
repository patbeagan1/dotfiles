
isMac () 
{ 
    if [ "Mac" = $(machinetype.sh) ]; then
        return 0;
    else
        return 1;
    fi
}

isLinux () 
{ 
    if [ "Linux" = $(machinetype.sh) ]; then
        return 0;
    else
        return 1;
    fi
}

isCygwin () 
{ 
    if [ "Cygwin" = $(machinetype.sh) ]; then
        return 0;
    else
        return 1;
    fi
}

isMinGw () 
{ 
    if [ "MinGw" = $(machinetype.sh) ]; then
        return 0;
    else
        return 1;
    fi
}