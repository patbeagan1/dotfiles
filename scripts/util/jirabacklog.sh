#!/usr/bin/env zsh 

# Function to list Jira backlog items and their assignees for a project.
# It requires jq to be installed (brew install jq).
#
# Usage: jirabacklog <PROJECT_KEY>
# Example: jirabacklog AC
#
function jirabacklog() {
  # 1. Validate input
  if [[ -z "$1" ]]; then
    echo "Error: Please provide a Jira project key." >&2
    echo "Usage: jirabacklog <PROJECT_KEY>" >&2
    return 1
  fi

  # 2. Check for dependencies
  if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it to use this function." >&2
    echo "On macOS, run: brew install jq" >&2
    return 1
  fi

  local project_key=$1

  # 3. Run the command and process the output
  acli jira workitem search --jql="project = '${project_key}' AND sprint is EMPTY ORDER BY Rank ASC" --json 2>/dev/null | \
  jq -r '.[] |
    # Extract the base Jira URL from the 'self' link to build the ticket URL
  ('https://alltrails.atlassian.net' as $baseUrl) |
    # Format and print the ticket info
    "🎟️  \(.fields.summary) - \(.fields.assignee.displayName // "Unassigned")\n\($baseUrl)/browse/\(.key)\n"'
}
jirabacklog "$@"
