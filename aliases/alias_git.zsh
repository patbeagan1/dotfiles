# Alias for viewing the last commit in a concise format
alias gitl='git last --oneline | cat'
# Alias for checking the status of the git repository
alias gss='git status -sb'
# Alias to revert a file to the version in the develop branch
alias revert-file='git checkout origin/develop --'
# Alias to revert all files to the version in the develop branch
alias revert-files='find . -exec git checkout origin/develop -- {} \;'

# Alias to list the last 10 branches
alias lb="last_branch.sh | tail -10"
# Alias to list branches excluding those marked as old
alias lbb="last_branch.sh | grep -v old"
# Alias to select and checkout a branch from the last 10 branches
alias lbf="git branch --sort=committerdate | tail -10 | fzf --tac --no-sort | xargs git checkout"

# Alias to view the git log in a simplified format
alias git-view='git log --graph --simplify-by-decoration --pretty=format:%d --all'
# Alias to view the git log with more details
alias git-view2='git log --graph --oneline --decorate --all'
# Alias to view the git log with detailed formatting
alias git-view3="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
# Alias to view the git log with detailed formatting and author information
alias git-view4="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all"
# Default alias for viewing git log
alias gv='git-view3'

# Alias for git command
alias g="git"
# Alias to push to the master branch
alias gpom="git push origin master"
# Alias to check the status of the git repository
alias gs="git status"
# Alias to list branches
alias gb="git branch"
# Alias to checkout a branch
alias gco="git checkout"
# Function to log commits over time
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

###########################################################
# Development
###########################################################

# Alias to get the current release version
alias getCurrentRelease="git branch -r | grep 'origin/release' | cut -d'/' -f 3-99 | grep -E '^\d+\.\d+\.\d+$' | sort -t . -k1,1n -k2,2n -k3,3n | tail -1"

gh-prs-last-6-months-all() {
  if [ "$#" -eq 0 ]; then
    echo "Error: No repositories supplied."
    echo "Usage: gh-prs-last-6-months-all <repo1> <repo2> ..."
    return 1
  fi
  local repos=("$@")
  for repo in "${repos[@]}"; do
    if [ -d "$repo/.git" ]; then
      echo ""
      echo "=================================================================="
      echo "Repository: $repo"
      echo "=================================================================="
      echo ""
      (cd "$repo" && gh-prs-last-6-months)
      echo ""
    else
      echo "Directory $repo is not a git repository."
    fi
  done
}


gh-prs-last-6-months() {
  # Detect the default base branch of the local repo (e.g., develop or main or master)
  local base_branch
  if git show-ref --verify --quiet refs/remotes/origin/develop; then
    base_branch="develop"
  elif git show-ref --verify --quiet refs/remotes/origin/main; then
    base_branch="main"
  elif git show-ref --verify --quiet refs/remotes/origin/master; then
    base_branch="master"
  else
    # fallback: use current branch
    base_branch=$(git symbolic-ref --short HEAD)
  fi

  local since_date=$(date -v-6m +%Y-%m-%d)
  local until_date=$(date +%Y-%m-%d)
  
  # Ask for the GitHub username directly and remember it for future use
  local author
  if [ -f ~/.gh_prs_author ]; then
    author=$(cat ~/.gh_prs_author)
  fi
  if [ -z "$author" ]; then
    read "author?Enter your GitHub username: "
    if [ -z "$author" ]; then
      echo "GitHub username is required."
      return 1
    fi
    echo "$author" > ~/.gh_prs_author
  fi

  echo "###########################################################"
  echo "#   GitHub PRs merged in the last 6 months (by ${author})"
  echo "###########################################################"
  gh pr list --limit 1000 --search "is:pr is:closed merged:${since_date}..${until_date} base:${base_branch} author:${author} sort:updated-desc" | cat

  echo ""
  echo "###########################################################"
  echo "#   GitHub PRs merged into branches other than ${base_branch} (by ${author})"
  echo "###########################################################"
  gh pr list --search "is:pr is:closed merged:${since_date}..${until_date} -base:${base_branch} author:${author} sort:updated-desc" | cat
}

gh-prs-awaiting-my-review() {
  local reviewer
  # Try to get GitHub username from cache or prompt
  if [ -f ~/.gh_prs_author ]; then
    reviewer=$(cat ~/.gh_prs_author)
  fi
  if [ -z "$reviewer" ]; then
    read "reviewer?Enter your GitHub username: "
    if [ -z "$reviewer" ]; then
      echo "GitHub username is required."
      return 1
    fi
    echo "$reviewer" > ~/.gh_prs_author
  fi

  echo "###########################################################"
  echo "#   GitHub PRs awaiting your review (${reviewer})"
  echo "###########################################################"
  gh pr list --search "is:pr is:open review-requested:${reviewer} -author:${reviewer} sort:updated-desc" --limit 100 --json number,title,url,updatedAt,reviews | \
    jq -r '
      .[] |
      # Collect reviewers who are not the current reviewer
      .reviewers = ([.reviews[]?.author.login] | unique | map(select(. != "'"${reviewer}"'"))) |
      # Calculate time since last update in days
      .updated_days_ago = ((now - ( ( .updatedAt | sub("\\..*";"") | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime ) )) / 86400 | floor) |
      # Mark as important if not reviewed by anyone else or last updated > 7 days ago
      .important = ( ( (.reviewers | length) == 0 ) or (.updated_days_ago > 7) ) |
      # Compose output
      "\u001b[1;34m\(.number):\u001b[0m \u001b[1;37m\(.title)\u001b[0m\(.important | if . then " ‼️" else "" end)\n" +
      "\u001b[36m\(.url)\u001b[0m\n" +
      "Reviewed by: \(.reviewers | if length == 0 then "\u001b[31mNo other reviewers\u001b[0m" else map("\u001b[38;5;30m" + . + "\u001b[0m") | join(", ") end)\n" +
      "Last updated: \(.updatedAt) (\(.updated_days_ago) days ago)\n"
    '
}

jira-my-tickets() {
  exit 1 # TODO: untested

  local jira_user
  # Try to get Jira username/email from cache or prompt
  if [ -f ~/.jira_user ]; then
    jira_user=$(cat ~/.jira_user)
  fi
  if [ -z "$jira_user" ]; then
    read "jira_user?Enter your Jira username or email: "
    if [ -z "$jira_user" ]; then
      echo "Jira username/email is required."
      return 1
    fi
    echo "$jira_user" > ~/.jira_user
  fi

  local jira_url
  if [ -f ~/.jira_url ]; then
    jira_url=$(cat ~/.jira_url)
  fi
  if [ -z "$jira_url" ]; then
    read "jira_url?Enter your Jira base URL (e.g., https://yourcompany.atlassian.net): "
    if [ -z "$jira_url" ]; then
      echo "Jira base URL is required."
      return 1
    fi
    echo "$jira_url" > ~/.jira_url
  fi

  local jql="assignee = \"$jira_user\" AND resolution = Unresolved ORDER BY updated DESC"
  echo "###########################################################"
  echo "#   Jira tickets currently assigned to you ($jira_user)"
  echo "###########################################################"
  if command -v jira &>/dev/null; then
    jira issue list --jql "$jql"
  else
    echo "Jira CLI not found. Trying with curl and basic auth."
    local jira_token
    if [ -f ~/.jira_token ]; then
      jira_token=$(cat ~/.jira_token)
    fi
    if [ -z "$jira_token" ]; then
      read -s "jira_token?Enter your Jira API token (input hidden): "
      if [ -z "$jira_token" ]; then
        echo "Jira API token is required."
        return 1
      fi
      echo "$jira_token" > ~/.jira_token
    fi
    curl -s -u "$jira_user:$jira_token" \
      -X GET \
      -H "Content-Type: application/json" \
      "$jira_url/rest/api/2/search?jql=$(echo $jql | jq -sRr @uri)&fields=key,summary,status" |
      jq -r '.issues[] | "\(.key): \(.fields.summary) [\(.fields.status.name)]"'
  fi
}
