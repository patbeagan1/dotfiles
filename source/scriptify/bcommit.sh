bcommit () 
{ 
    function getbranch () 
    { 
        printf $(git rev-parse --abbrev-ref HEAD)
    };
    git commit -am "PT$(getbranch | sed 's/[^0-9]//g') $(getbranch | sed 's/^lb-//g' | sed 's/^fb-//g' | sed 's/^pt//g' | sed 's/^PT//g' | tr '-' ' ' | tr '_' ' ' | sed 's/[0-9]//g')
$(echo)
$@
$(echo)
https://admin.wayfair.com/tracker/views/142.php?prtid=$(getbranch | sed 's/[^0-9]//g')"
}
if [[ $0 != "-bash" ]]; then bcommit "$@"; fi
