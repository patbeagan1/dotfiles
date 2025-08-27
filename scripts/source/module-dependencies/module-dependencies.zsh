#!/bin/zsh

:<< COMMENT
This will print all of the import statements which are in files under the 
current directory. It can be used to plan for what kind of module we'll 
need to create in order to extract all of the contents of the current folder.
COMMENT

ag import --nogroup --nofilename | sed 's/;//g' | sort | uniq
