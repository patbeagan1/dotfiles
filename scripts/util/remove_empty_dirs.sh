#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

remove_empty_dirs () 
{ 
    find . -type d -empty | xargs -I % rmdir %
}

remove_empty_dirs "$@"
