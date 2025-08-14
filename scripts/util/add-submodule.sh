#!/usr/bin/env zsh

set -euo pipefail

scriptname="$(basename "$0")"

usage() {
  cat <<EOF
Usage: $scriptname [-h|--help] [-b <branch>] <repo_url> [submodule_path]

Adds a git submodule to the project.

Arguments:
  repo_url         The URL of the git repository to add as a submodule.
  submodule_path   (Optional) Path where the submodule will be placed. Defaults to the repo name.

Options:
  -b, --branch     Specify a branch to track for the submodule.
  -h, --help       Show this help message and exit.

Examples:
  $scriptname https://github.com/user/repo.git
  $scriptname -b main https://github.com/user/repo.git libs/repo
EOF
  exit 1
}

add_submodule() {
  local branch=""
  local repo_url=""
  local submodule_path=""

  # Parse options
  zparseopts -D -E -F -b:=branch_opt -branch:=branch_opt -h=help_opt -help=help_opt

  if (( ${#help_opt} )); then
    usage
  fi

  if (( ${#branch_opt} )); then
    branch="${branch_opt[2]}"
    if [[ -z "$branch" ]]; then
      echo "❌ Error: --branch requires a value."
      usage
    fi
  fi

  # Shift parsed options
  while [[ "$1" == -* ]]; do shift; done

  # Parse positional arguments
  if [[ $# -lt 1 ]]; then
    echo "❌ Error: repo_url is required."
    usage
  fi

  repo_url="$1"
  submodule_path="${2:-}"

  # If submodule_path is not provided, derive from repo_url
  if [[ -z "$submodule_path" ]]; then
    submodule_path="${repo_url:t:r}"
  fi

  echo "🔹 Adding submodule:"
  echo "    Repo URL:        $repo_url"
  echo "    Submodule Path:  $submodule_path"
  if [[ -n "$branch" ]]; then
    echo "    Branch:          $branch"
    git submodule add -b "$branch" "$repo_url" "$submodule_path"
  else
    git submodule add "$repo_url" "$submodule_path"
  fi

  echo "🔹 Initializing and updating submodule..."
  git submodule update --init --recursive "$submodule_path"

  echo "✅ Submodule added successfully."
}

add_submodule "$@"
