lastfield () 
{ 
    awk -F "/" '{print $NF}'
}
