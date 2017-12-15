#!/bin/bash
scriptify ()
{
    if [[ "$(type "$1")" == *"is a shell builtin" ]]; then
        echo This is a shell builtin.;
    else
        if [[ "$(type "$1")" == *"is aliased to"* ]]; then
            echo This is an alias.;
        else
            type "$1" | tail -n +2 | tee "$1".sh && chmod 755 "$1".sh;
            echo "if [[ \$0 != \"-bash\" ]]; then $1 \"\$@\"; fi" >> "$1".sh;
        fi;
    fi
}
