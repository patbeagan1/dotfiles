
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
