bcommit () 
{ 
    if [ $(echo "$@" | grep -c .*[0-9].*) -eq 0 ]; then
        function getbranch () 
        { 
            printf $(git rev-parse --abbrev-ref HEAD)
        };
        prefix="$(getbranch |sed 's/^lb-.*/PT/g' |sed 's/^fb-.*/PT/g' |sed 's/^fabric-.*/NOTICKET Fabric/g' |sed 's/^pt.*/PT/g' |sed 's/^PT.*/PT/g')";
        number="$(getbranch | sed 's/[^0-9]//g')";
        title="$(getbranch |sed 's/^lb-//g' |sed 's/^fb-//g' |sed 's/^fabric-//g' |sed 's/^pt//g' |sed 's/^PT//g' |tr '-' ' ' |tr '_' ' ' |sed 's/[0-9]//g' |sed 's/^ //g')

";
        body="$(
echo $@ |sed 's/BULLET/\
- /g' |sed 's/NEWLINE/\
/g'
)

";
        adminUrl="$(if [[ $(getbranch) != "fabric-"* ]] ; then
    echo https://admin.wayfair.com/tracker/views/142.php?prtid=$(getbranch | sed 's/[^0-9]//g')
else
    echo Fabric $(getbranch | sed 's/[^0-9]//g')
fi)
";
        commitText="$prefix$number $title$body$adminUrl";
        echo "$commitText";
        git commit -am "$commitText";
        echo;
        echo Use the below as a template for your Ticket.;
        echo --------------------------------------------;
        echo;
        echo "$body";
        echo "**This is ready for QA.**";
        echo;
        echo Branch: $(getbranch);
        echo MR: TBD;
        echo FT: TBD;
        echo ACC:;
        echo - TBD;
    else
        echo "There are numbers in \"$@\", fix your commit message first.";
    fi
}