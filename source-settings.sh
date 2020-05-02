export MYHOME=$HOME/Downloads/MyHome

ps_padding()
# Does the formatting for the terminal prompt
{
    parse_git_branch()
    {
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
        git rev-list --count HEAD 2> /dev/null
    }
    echo " $(date +"%H:%M:%S")$(parse_git_branch)" | tr "\n" " "
}

# Terminal settings
export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\[\033[32m\]\$(ps_padding)\[\033[00m\]\$ "
export CLICOLOR=1
export LSCOLORS=exfxcxdxbxexexabagacad
export LSCOLORS=Exfxcxdxbxegedabagacad # Brighter colors in this one. Last one wins.
export HISTTIMEFORMAT="%F %T "
shopt -s histappend

# adding the script directories to the path
export PATH=$PATH:~/libbeagan/scripts
export PATH=$PATH:~/libbeagan/scripts/util
export PATH=$PATH:~/libbeagan/scripts/image_manipulation
export PATH=$PATH:~/libbeagan/scripts/file_management
export PATH=$PATH:~/libbeagan/scripts/math
export PATH=$PATH:~/libbeagan/scripts/sysadmin
export PATH=$PATH:~/libbeagan/scripts/vcs
export PATH=$PATH:~/libbeagan/scripts/android
export PATH=$PATH:~/libbeagan/scripts/dev
