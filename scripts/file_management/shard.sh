#!/bin/bash
# (c) 2022 Pat Beagan: MIT License

. $LIB_MACHINE_TYPES

shard () 
{ 
    function perform_shard () 
    { 
        for i in $(find . -maxdepth 1 ! -name shard -type f);
        do
            ## Setting hashsum
            if isLinux; then
                a="$(md5sum $i | sed 's/ .*//g')";
            else
                if isMac; then
                    temp="$(md5 $i)";
                    a="${temp##* }";
                else
                    echo Unsupported OS && return 1;
                fi;
            fi;

            ## Minifying hashsum
            b=$(echo "${a:0:1}");
            
            ## If the mini hashsum is valid, we can proceed with moving the file there.
            valid="0 1 2 3 4 5 6 7 8 9 a b c d e f";
            if [[ " $valid " =~ " $b " ]]; then
                mkdir -pv -p "$b";
                if isMac; then
                    gmv --backup=numbered "$i" "$b";
                fi;
                if isLinux; then
                    mv --backup=numbered "$i" "$b";
                fi;
            else
                echo "$a Was not a valid minified hashsum.";
            fi;
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
trackusage.sh "$0"
