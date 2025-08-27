#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

cputemp-linux.sh |
    awk '{ 
         printf "%s ", $NF; 
         for(i=1;i<NF;i++){
             printf "%s ", $i
         }; 
        printf "\n" 
    }' |
    sort -nr
