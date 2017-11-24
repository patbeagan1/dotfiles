bcommit-fix () 
{ 
    function getbranch () 
    { 
        printf $(git rev-parse --abbrev-ref HEAD)
    };
    function gettitle () 
    { 
        echo PT$(getbranch | sed 's/[^0-9]//g')$(getbranch | tr '_' ' ' | sed 's/pt//g' | sed 's/[0-9]//g');
        echo
    };
    function getfooter () 
    { 
        echo;
        printf https://admin.wayfair.com/tracker/views/142.php?PrtID=$(getbranch | sed 's/[^0-9]//g')
    };
    git commit --amend -m "$(cat <(gettitle) <(git last) <(getfooter))"
}
if [[ $0 != "-bash" ]]; then bcommit-fix "$@"; fi
