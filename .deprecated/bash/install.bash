
export LIBBEAGAN="$HOME/libbeagan"

# setting up terminal prompt
source $LIBBEAGAN/bash/prompts/source-prompt-1.sh

# setting up external resources
$LIBBEAGAN/bash/external-resources.sh

export CLICOLOR=1
export LSCOLORS=exfxcxdxbxexexabagacad
export LSCOLORS=Exfxcxdxbxegedabagacad # Brighter colors in this one. Last one wins.
export HISTTIMEFORMAT="%F %T "
shopt -s histappend

export MYHOME=$HOME/Downloads/MyHome

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

# [Sat May 02 17:11 ~/.img_cache]
source-prompt-2 () 
{ 
    PS1='\[\e]0;\w\a\]\n\[\e[00;33m\][\d \A \[\e[01;35m\]\w\[\e[00;33m\]]\[\e[0m\] \[\033[1;32m\]\[\033[0m\] \n\$ '
}

# [Sat May 02 17:11 ~/.img_cache]
source-prompt-minimal () 
{ 
    PS1='$ '
}