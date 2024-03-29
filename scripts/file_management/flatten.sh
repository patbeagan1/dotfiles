#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

flatten () 
{ 
    test -d __flattened_files || mkdir __flattened_files;
    which gmv > /dev/null && find "$1" -type f -exec gmv --backup=numbered $(echo '{}') __flattened_files \;
}

flatten "$@"
trackusage.sh "$0"