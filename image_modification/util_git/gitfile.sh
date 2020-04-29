gitfile () 
{ 
    git status --porcelain | sed s/^...//
}
