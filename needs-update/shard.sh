#!/bin/bash 

shard () 
{ 
    function perform_shard () 
    { 
        for i in $(find . -maxdepth 1 ! -name shard -type f);
        do
            a="$(md5sum $i | sed 's/ .*//g')";
            b=$(echo "${a:0:1}");
            mkdir -p "$b";
            mv "$i" "$b";
        done
    };
    if [ $# -ne 1 ]; then
        echo Please specify a directory to shard. The files in that directory will be reassigned to an alphanumeric directory. Best used with flatten.;
    else
        directory="$1";
        cd "$directory" && rename 'y/ /_/' * && perform_shard;
    fi
}

shard "$@"
