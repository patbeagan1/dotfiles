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

  # 3. Read or prompt for Jira instance subdomain (copied from jirasprintmine)
  local jira_subdomain_file="$HOME/.jira_instance_subdomain"
  local JIRA_INSTANCE_SUBDOMAIN=""

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

  local project_key=$1
  local jql_query

  # 4. Safely build the JQL query string using printf
  printf -v jql_query "project = '%s' AND sprint is EMPTY ORDER BY Rank ASC" "${project_key}"

  # 5. Run the command and process the output, using the dynamic Jira subdomain
  acli jira workitem search --jql="$jql_query" --json 2>/dev/null | \
  JIRA_INSTANCE_SUBDOMAIN="$JIRA_INSTANCE_SUBDOMAIN" jq -r '
    .[] |
    "🎟️  \(.fields.summary) - \(.fields.assignee.displayName // "Unassigned")\nhttps://" + (env.JIRA_INSTANCE_SUBDOMAIN) + ".atlassian.net/browse/" + .key + "\n"
  '
}
jirabacklog "$@"
