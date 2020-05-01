killport () 
{ 
    sudo kill $(sudo lsof -t -i:$1)
}
