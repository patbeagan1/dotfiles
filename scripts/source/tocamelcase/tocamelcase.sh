#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

tocamelcase () 
{ 
    echo "$1" | perl -pe 's/(^|_)./uc($&)/ge;s/_//g'
}

tocamelcase "$@"
