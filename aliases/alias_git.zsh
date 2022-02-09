alias lbf="git branch --sort=committerdate | tail -10 | fzf | xargs git checkout"
alias git-view='git log --graph --simplify-by-decoration --pretty=format:%d --all'
alias git-view2='git log --graph --oneline --decorate --all'
alias git-view3="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
alias git-view4="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all"
alias gv='git-view3'

alias g="git"
alias gpom="git push origin master"
alias gs="git status"
alias gb="git branch"
alias gco="git checkout"
