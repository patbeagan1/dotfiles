switchoc () { git switch "$1" 2>/dev/null || git switch -c "$1"; git fetch "$1" 2>/dev/null; }
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

ai_commit() {

  # Generate a Conventional Commit message from staged Git changes using Ollama
  ### === Configuration ===

  local MODEL="llama3"
  local PROMPT=$(cat <<'EOF'
**Important:** You are a function that strictly outputs your return value. DO NOT include any explanations, or other text, such as "Here is the commit message:".

Generate a Conventional Commit message from the following Git diff.
Follow the Conventional Commits specification (https://www.conventionalcommits.org):
- Format: <type>[optional scope]: <description>
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- Use present tense, concise wording (e.g., "fix: prevent crash on null input")
- Scope is optional and should be in parentheses after the type if present
EOF
)

  ### === Logging ===

  log()  { print -P "%F{blue}ℹ%f $*"; }
  warn() { print -P "%F{yellow}⚠%f $*" >&2; }
  die()  { print -P "%F{red}✖%f $*" >&2; return 1; }

  ### === Subroutines ===

  check_repo() {
    git rev-parse --is-inside-work-tree &>/dev/null || die "Not in a Git repository."
  }

  get_diff() {
    local diff=$(git diff --cached)
    [[ -z "$diff" ]] && die "No staged changes to commit."
    echo "$diff"
  }

  generate_message() {
    local diff="$1"
    local msg=$(ollama run "$MODEL" "${PROMPT}${diff}") || die "Ollama generation failed."
    msg=$(echo "$msg" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [[ -z "$msg" ]] && die "Generated message is empty."
    echo "$msg"
  }

  confirm() {
    echo -n "💬 Proceed with commit? (y/N): "
    read -r reply
    [[ "$reply" == [yY] ]]
  }

  commit() {
    git commit -m "$1" || die "Git commit failed."
    log "Commit successful."
  }

  check_repo
  local diff=$(get_diff)

  log "Generating commit message with $MODEL..."
  local msg=$(generate_message "$diff")

  print -P "\n%F{cyan}📋 Commit message:%f"
  echo "----------------------------------------"
  echo "$msg"
  echo "----------------------------------------"

  confirm && commit "$msg" || warn "Commit canceled."
}

# fzf wrapper to group useful git/jira/gh functions for quick access
git_tools_fzf() {
  local options=(
    "1. gh-prs-last-6-months         View your PRs from the last 6 months in this repo"
    "2. gh-prs-last-6-months-all     View your PRs from the last 6 months in multiple repos"
    "3. jirasprintmine               List your Jira issues in open sprints"
    "4. git-over-time                Show commit dates and authors"
    "5. getCurrentRelease            Show the latest release branch"
    "6. gv (git-view3)               Pretty git log graph"
    "7. gs (git status)              Show git status"
    "8. gb (git branch)              List branches"
    "9. gco (git checkout)           Checkout a branch"
    "10. lbf                         Fuzzy checkout from last 10 branches"
    "11. lbb                         Show last branch"
    "12. Exit"
  )
  local choice
  choice=$(printf '%s\n' "${options[@]}" | fzf --prompt="Select a git/jira tool: " --height=80% --border --ansi)
  case "$choice" in
    "1."*) gh-prs-last-6-months ;;
    "2."*) 
      echo "Enter repo directories (space-separated):"
      read -r repos
      gh-prs-last-6-months-all $repos
      ;;
    "3."*) jirasprintmine ;;
    "4."*) git-over-time ;;
    "5."*) getCurrentRelease ;;
    "6."*) gv ;;
    "7."*) gs ;;
    "8."*) gb ;;
    "9."*) 
      echo "Enter branch to checkout:"
      read -r branch
      gco "$branch"
      ;;
    "10."*) lbf ;;
    "11."*) lbb ;;
    *) echo "Exiting." ;;
  esac
}
alias gtools="git_tools_fzf"

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

  # Get PRs awaiting review, including headRefName and mergeable status
  gh pr list --search "is:pr is:open review-requested:${reviewer} -author:${reviewer} sort:updated-desc" --limit 100 --json number,title,url,updatedAt,reviews,headRefName,mergeable | \
    jq -r '
      .[] |
      # Collect reviewers who are not the current reviewer
      .reviewers = ([.reviews[]?.author.login] | unique | map(select(. != "'"${reviewer}"'"))) |
      # Calculate time since last update in days
      .updated_days_ago = ((now - ( ( .updatedAt | sub("\\..*";"") | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime ) )) / 86400 | floor) |
      # Mark as important if not reviewed by anyone else or last updated > 7 days ago
      .important = ( ( (.reviewers | length) == 0 ) or (.updated_days_ago > 7) ) |
      # Compose output, with last updated as relative days and conflicts inline
      (.important | if . then "‼️ " else "" end) + "\u001b[1;34m\(.number):\u001b[0m \u001b[1;37m\(.title)\u001b[0m\n" +
      "\u001b[36m\(.url)\u001b[0m\n" +
      "Reviewed by: \(.reviewers | if length == 0 then "\u001b[31mNo other reviewers\u001b[0m" else map("\u001b[38;5;30m" + . + "\u001b[0m") | join(", ") end)\n" +
      (
        "Last updated: " +
        (
          if .updated_days_ago <= 1 then
            "\u001b[32m\(.updated_days_ago) days ago\u001b[0m" # green for 0-1 days
          elif .updated_days_ago <= 3 then
            "\u001b[33m\(.updated_days_ago) days ago\u001b[0m" # yellow for 2-3 days
          elif .updated_days_ago <= 7 then
            "\u001b[35m\(.updated_days_ago) days ago\u001b[0m" # magenta for 4-7 days
          else
            "\u001b[31m\(.updated_days_ago) days ago\u001b[0m" # red for >7 days
          end
        )
      ) +
      (if .mergeable == "CONFLICTING" then " \u001b[31m⚠️ Has conflicts with develop\u001b[0m" else "" end) + "\n"
    '
}

jirasprintmine() {
  # File to cache the Jira instance subdomain
  local jira_subdomain_file="$HOME/.jira_instance_subdomain"
  local JIRA_INSTANCE_SUBDOMAIN=""

  # Try to read the Jira instance subdomain from file, or prompt if not found
  if [[ -f "$jira_subdomain_file" ]]; then
    JIRA_INSTANCE_SUBDOMAIN=$(<"$jira_subdomain_file")
  fi
  if [[ -z "$JIRA_INSTANCE_SUBDOMAIN" ]]; then
    read "JIRA_INSTANCE_SUBDOMAIN?Enter your Jira instance subdomain (the part before .atlassian.net): "
    if [[ -z "$JIRA_INSTANCE_SUBDOMAIN" ]]; then
      echo "Jira instance subdomain is required."
      return 1
    fi
    echo "$JIRA_INSTANCE_SUBDOMAIN" > "$jira_subdomain_file"
  fi

  # Query Jira for current user's issues in open sprints, output as JSON
  local json
  # Recommended JQL to better understand current work left in the sprint:
  # - Exclude issues that are already Done/Closed/Resolved (adjust status names as needed for your Jira instance)
  # - Optionally, group by status or order by priority/updated
  # - Show only issues in the current active sprint assigned to you and not completed
  json=$(acli jira workitem search --jql='assignee = currentUser() AND sprint in openSprints() AND statusCategory != Done ORDER BY priority DESC, updated DESC' --json 2>/dev/null)
  if [[ -z "$json" || "$json" == "[]" ]]; then
    echo "No Jira issues assigned to you in open sprints."
    return 0
  fi

  # Pretty print the issues with useful info
  echo "###########################################################"
  echo "#   Jira Issues Assigned to You in Open Sprints"
  echo "###########################################################"
  echo ""
  echo "$json" | JIRA_INSTANCE_SUBDOMAIN="$JIRA_INSTANCE_SUBDOMAIN" jq -r '
    .[] |
    # Compose key, summary, status, and URL using the correct fields path
    "\u001b[1;34m\(.key)\u001b[0m: \u001b[1;37m\(.fields.summary)\u001b[0m\n" +
    "Status: \u001b[36m\(.fields.status.name)\u001b[0m | " +
    "Type: \u001b[35m\(.fields.issuetype.name)\u001b[0m | " +
    "Priority: \u001b[33m\(.fields.priority.name // "N/A")\u001b[0m\n" +
    "Assignee: \u001b[32m\(.fields.assignee.displayName // "Unassigned")\u001b[0m\n" +
    "URL: \u001b[4;36mhttps://" + (env.JIRA_INSTANCE_SUBDOMAIN) + ".atlassian.net/browse/" + .key + "\u001b[0m\n" +
    "-----------------------------------------------------------"
  '
}

# fzf launcher for gh (GitHub CLI) commands.
# Usage: Type 'ghf' and press Enter.
ghf() {
  # 1. Check for dependencies
  if ! command -v fzf &>/dev/null || ! command -v gh &>/dev/null; then
    echo "Error: This function requires 'fzf' and 'gh' to be installed." >&2
    return 1
  fi

  # 2. Get a list of commands by parsing the 'gh' help output
  local commands
  commands=$(gh | grep -E '^\s+\w+:' | awk '{print $1}' | sed 's/://g')
  if [[ -z "$commands" ]]; then
    echo "Error: Could not parse commands from 'gh'." >&2
    return 1
  fi

  # 3. Set up the fzf preview command, using 'bat' if available
  local preview_cmd
  if command -v bat &> /dev/null; then
    # Use 'bat' for syntax-highlighted help text
    preview_cmd="gh {} --help | bat -l help -p --color=always"
  else
    preview_cmd="gh {} --help"
  fi

  # 4. Run fzf to let the user select a command
  local selected_command
  selected_command=$(echo "$commands" | fzf --height 50% --min-height 15 --border --prompt="GitHub CLI > " \
    --preview="$preview_cmd" \
    --preview-window='right,70%,border-left')

  # 5. If a command was selected, place it on the command line
  if [[ -n "$selected_command" ]]; then
    print -z "gh ${selected_command} "
  fi
}

# fzf launcher for git commands.
# Usage: Type 'gfh' and press Enter.
gfh() {
  # 1. Check for dependencies
  if ! command -v fzf &>/dev/null || ! command -v git &>/dev/null; then
    echo "Error: This function requires 'fzf' and 'git' to be installed." >&2
    return 1
  fi

  # 2. Get a reliable list of all git commands
  local commands
  commands=$(ls "$(git --exec-path)" | sed 's/^git-//')
  if [[ -z "$commands" ]]; then
    echo "Error: Could not list git commands from exec-path." >&2
    return 1
  fi

  # 3. Set up the fzf preview command, using 'bat' for syntax highlighting if available
  local preview_cmd
  if command -v bat &> /dev/null; then
    preview_cmd="git help {} | bat -l help -p --color=always"
  else
    preview_cmd="git help {}"
  fi

  # 4. Run fzf to let the user select a command
  local selected_command
  selected_command=$(echo "$commands" | fzf --height 60% --min-height 20 --border --prompt="Git > " \
    --preview="$preview_cmd" \
    --preview-window='right,70%,border-left')

  # 5. If a command was selected, place it on the command line for editing
  if [[ -n "$selected_command" ]]; then
    print -z "git ${selected_command} "
  fi
}




