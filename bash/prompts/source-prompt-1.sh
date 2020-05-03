#!/bin/bash

# pbeagan@Patricks-MacBook-Pro:~/libbeagan/bash/prompts 17:24:14 (master) 150 $
source-prompt-1 () 
{ 
    function ps_padding () 
    { 
        function parse_git_branch () 
        { 
            git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/';
            git rev-list --count HEAD 2> /dev/null
        };
        echo " $(date +"%H:%M:%S")$(parse_git_branch)" | tr "\n" " "
    };
    export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\[\033[32m\]\$(ps_padding)\[\033[00m\]\$ "
}

source-prompt-1 "$@"
