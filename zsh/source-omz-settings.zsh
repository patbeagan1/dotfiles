
prompt_ps_padding () 
{ 
    prompt_parse_git_branch () 
    { 
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/';
        git rev-list --count HEAD 2> /dev/null
    };
    echo " $(date +"%H:%M:%S")$(prompt_parse_git_branch)" | tr "\n" " "
};

##############
### Themes ###
##############

# ZSH_THEME="pygmalion"
export PROMPT="%F{cyan}%n%F{white}@%F{green}$(ipconfig getifaddr en0):%F{yellow}%~%F{green}\$(prompt_ps_padding)%F{white}%% "
# ZSH_THEME="lukerandall"
# PROMPT='%F{green}%n%f@%F{magenta}%m%f %F{blue}%B%~%b%f %# '
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# DISABLE_AUTO_UPDATE="true"
# DISABLE_UPDATE_PROMPT="true"
# export UPDATE_ZSH_DAYS=13

# COMPLETION_WAITING_DOTS="true"
plugins=(git)

