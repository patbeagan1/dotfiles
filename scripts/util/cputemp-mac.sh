#!/bin/bash

check_install() {
    if hash "$1" 2>/dev/null; then
        exit 0
    else
        read -p "$1 is not installed. Want to install it?" -n 1 -r;
        echo;
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            local com=""
            case "$1" in
                iStats*)
                    com="gem install iStats"
                ;;
                *)
                    com=""
                ;;
            esac;
            eval "$com"
            exit $?
        fi
    fi
}

cputemp () {
    if isMac.sh; then
        check_install.sh iStats
        c=$(iStats | grep 'CPU temp' | sed s/[a-zA-Z\ :]*// | sed s/°.*//);
        echo "9*$c/5+32" | bc -l;
    else
        echo This will only work on a mac computer. Exiting.
        exit 1
    fi
}

cputemp "$@"
trackusage.sh "$0"