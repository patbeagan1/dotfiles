
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=2000
SAVEHIST=5000
setopt AUTO_CD
setopt CORRECT
setopt CORRECT_ALL
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt NO_AUTO_MENU
setopt NO_CASE_GLOB
setopt NO_MENU_COMPLETE
setopt SHARE_HISTORY

prompt_ps_padding () 
{ 
    prompt_parse_git_branch () 
    { 
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/';
        git rev-list --count HEAD 2> /dev/null
    };
    echo " $(date +"%H:%M:%S")$(prompt_parse_git_branch)" | tr "\n" " "
};
export PROMPT="%F{cyan}%n%F{white}@%F{green}%M:%F{yellow}%~%F{green}\$(prompt_ps_padding)%F{white}%% "

# PROMPT='%F{green}%n%f@%F{magenta}%m%f %F{blue}%B%~%b%f %# '
ZSH_THEME="lukerandall"