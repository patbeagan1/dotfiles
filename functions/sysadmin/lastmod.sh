lastmod () 
{ 
    if [ `uname` = "Darwin" ]; then
        find . -type f -print0 | xargs -0 stat -f "%m %N" | sort -rn | head -5 | cut -f2- -d" ";
    else
        if [ `uname` = "Linux" ]; then
            find $1 -type f -print0 | xargs -0 stat --format '%Y :%y %n' | sort -nr | cut -d: -f2- | head;
        else
            echo 'No suitable command for this system.';
        fi;
    fi
}
