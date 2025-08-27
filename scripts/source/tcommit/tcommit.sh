#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

tcommit () 
{ 
    echo "t" >> test.txt && git add --all && git commit -am "test"
}

tcommit "$@"
