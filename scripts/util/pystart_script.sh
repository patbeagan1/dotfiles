#!/bin/bash

main () 
{ 
    echo '#!/usr/bin/env python3' > "$1".py;
    echo >> "$1".py;
    echo import os, time >> "$1".py
    echo from sys import argv >> "$1".py;
    echo >> "$1".py
    echo 'if __name__ == "__main__":' >> "$1".py
    echo '    pass' >> "$1".py
    chmod 755 "$1".py;
    code "$1".py
}

main "$@"
