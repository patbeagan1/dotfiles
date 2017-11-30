reset_origin () 
{ 
    function getbranch () 
    { 
        printf $(git rev-parse --abbrev-ref HEAD)
    };
    echo This is a hard reset.;
    read -p "Are you sure you want to check out origin/$(getbranch)? " -n 1 -r;
    echo;
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git fetch && git reset --hard origin/$(getbranch);
    fi
}
if [[ $0 != "-bash" ]]; then reset_origin "$@"; fi
