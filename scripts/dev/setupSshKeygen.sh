#!/bin/bash 

ssh-keygen && printf "\neval \`ssh-agent -s\`\nssh-add ~/.ssh/id_rsa" >> ~/.bash_profile
