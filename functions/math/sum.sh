sum () 
{ 
    echo "$1" | tr ',' '+' | bc
}
