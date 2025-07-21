switchoc () { git switch "$1" 2>/dev/null || git switch -c "$1"; git fetch "$1" 2>/dev/null; }
alias gitl='git last --oneline | cat'
alias gss='git status -sb'
alias revert-file='git checkout origin/develop --'
alias revert-files='find . -exec git checkout origin/develop -- {} \;'

alias lb="last_branch.sh | tail -10"
alias lbb="last_branch.sh | grep -v old"
alias lbf="git branch --sort=committerdate | tail -10 | fzf --tac --no-sort | xargs git checkout"

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
git-over-time() {  git log --format=format:'%as,%ae';  }

###########################################################
# Git Configuration
###########################################################

git config --global alias.co checkout
git config --global alias.revert-file 'checkout origin/develop --'
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'
git config --global alias.mergetest '!f(){ git merge --no-commit --no-ff "$1"; git merge --abort; echo "Merge aborted"; };f'
git config --global alias.work 'log --pretty=format:"%h%x09%an%x09%ad%x09%s"'
