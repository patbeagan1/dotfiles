#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

ssh-keygen && printf "\neval \`ssh-agent -s\`\nssh-add ~/.ssh/id_rsa" >> ~/.bash_profile
trackusage.sh "$0"