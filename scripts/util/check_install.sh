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
check_install "$@"