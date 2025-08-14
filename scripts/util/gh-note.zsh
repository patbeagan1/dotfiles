#!/usr/bin/env zsh

# ==============================================================================
# A Zsh CLI note-taking application using gh issues as the backend.
# Assumes the current directory is the repository for notes.
# ==============================================================================

# ------------------------------------------------------------------------------
# Configuration: Edit these variables to match your setup.
# ------------------------------------------------------------------------------

# The label used to identify notes. This helps separate your notes
# from other issues in the repository. Make sure this label exists.
NOTE_LABEL="note-app"

# ------------------------------------------------------------------------------
# Helper functions
# ------------------------------------------------------------------------------

# Get the user's preferred editor, or default to vim
EDITOR="${EDITOR:-vim}"

# Function for error handling
_error() {
  echo "Error: $1" >&2
  exit 1
}

# Function to get note body via the user's editor
_get_body_from_editor() {
  local temp_file=$(mktemp)
  local initial_body="$1"

  echo "$initial_body" > "$temp_file"
  
  "$EDITOR" "$temp_file" < `tty` > `tty`
  
  # Wait for the editor to close
  if ! [ $? -eq 0 ] ; then
    _error "Editor failed. Aborting."
  fi
  
  cat "$temp_file"
  rm "$temp_file"
}

# Function to select a note using fzf
_select_note_with_fzf() {
  local list_output
  list_output=$(gh issue list --label "$NOTE_LABEL" --state "open" \
    --json number,title | jq -r '.[] | "\(.number) \(.title)"' | fzf)
  
  if [[ -z "$list_output" ]]; then
    _error "No note selected."
  fi
  
  # Extract the issue number from the beginning of the line
  echo "$list_output" | awk '{print $1}'
}

# ------------------------------------------------------------------------------
# Core functions for the note-taking app
# ------------------------------------------------------------------------------

# Function to create a new note
create_note() {
  echo "Enter note title:"
  read -r title
  
  if [[ -z "$title" ]]; then
    _error "Note title cannot be empty. Creation aborted."
  fi

  echo "Opening editor for note body. Save and exit to finish."
  body=$(_get_body_from_editor)
  
  echo "Creating note..."
  gh issue create --title "$title" --body "$body" --label "$NOTE_LABEL" > /dev/null
  if [[ "$?" -ne 0 ]]; then
    _error "Failed to create note. Please check your repository and gh authentication."
  else
    echo "Note created successfully."
  fi
}

# Function to list all notes
list_notes() {
  echo "Fetching notes from the current repository..."
  gh issue list --label "$NOTE_LABEL" --state "open" \
    --json number,title | jq -r '.[] | "(\(.number)) \(.title)"'
}

# Function to view a specific note
view_note() {
  local issue_number="$1"
  echo "Fetching note #$issue_number..."

  gh issue view "$issue_number" --json title,body | jq -r '
    "Title: \(.title)\n---\n\n\(.body)\n"'
}

# Function to open a specific note in the browser
open_note() {
  local issue_number="$1"
  echo "Opening note #$issue_number in the browser..."
  
  local url=$(gh issue view "$issue_number" --json url | jq -r '.url')
  
  # Use the correct command to open the URL based on the OS
  if [[ "$OSTYPE" == "darwin"* ]]; then
    open "$url"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    xdg-open "$url"
  else
    _error "Unsupported OS. Please open the following URL manually: $url"
  fi
}

# Function to edit a specific note
edit_note() {
  local issue_number="$1"
  echo "Fetching note #$issue_number for editing..."
  
  local current_data=$(gh issue view "$issue_number" --json title,body)
  local current_title=$(echo "$current_data" | jq -r '.title')
  local current_body=$(echo "$current_data" | jq -r '.body')

  echo "Current title: $current_title"
  read -r "new_title?Enter new title (or press Enter to keep the current one): "
  
  if [[ -z "$new_title" ]]; then
    new_title="$current_title"
  fi
  
  echo "Opening editor for the note body. Edit, save, and exit."
  local updated_body=$(_get_body_from_editor "$current_body")
  
  gh issue edit "$issue_number" --title "$new_title" --body "$updated_body" > /dev/null
  if [[ "$?" -ne 0 ]]; then
    _error "Failed to update note #$issue_number."
  else
    echo "Note #$issue_number updated successfully."
  fi
}

# Function to add a comment to a note
comment_note() {
  local issue_number="$1"
  echo "Adding a comment to note #$issue_number."

  echo "Opening editor for your comment. Save and exit to submit."
  local comment_body=$(_get_body_from_editor)

  if [[ -z "$comment_body" ]]; then
    _error "Comment body cannot be empty. Commenting aborted."
  fi

  gh issue comment "$issue_number" --body "$comment_body" > /dev/null
  if [[ "$?" -ne 0 ]]; then
    _error "Failed to add comment to note #$issue_number."
  else
    echo "Comment added to note #$issue_number successfully."
  fi
}


# Function to "delete" (close) a note
delete_note() {
  local issue_number="$1"
  echo "Are you sure you want to delete note #$issue_number? (y/N)"
  read -r confirmation
  
  if [[ "$confirmation" =~ ^[Yy]$ ]]; then
    echo "Closing note #$issue_number..."
    gh issue close "$issue_number"
    if [[ "$?" -ne 0 ]]; then
      _error "Failed to close note #$issue_number."
    else
      echo "Note #$issue_number closed successfully."
    fi
  else
    echo "Deletion canceled."
  fi
}

# ------------------------------------------------------------------------------
# Main script logic
# ------------------------------------------------------------------------------

# Check for required dependencies
command -v gh >/dev/null 2>&1 || { _error "GitHub CLI (gh) is not installed."; }
command -v jq >/dev/null 2>&1 || { _error "jq is not installed. Please install it."; }
command -v fzf >/dev/null 2>&1 || { _error "fzf is not installed. Please install it."; }

# Check for git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    _error "Not in a git repository. Please run this script from inside the repository you want to use for notes."
fi

# Main command-line parser
case "$1" in
  create)
    create_note
    ;;
  list)
    list_notes
    ;;
  view)
    shift
    if [[ -z "$1" ]]; then
      issue_number=$(_select_note_with_fzf)
      [[ -z "$issue_number" ]] && exit 0 # Exit if fzf was cancelled
      view_note "$issue_number"
    else
      view_note "$@"
    fi
    ;;
  open)
    shift
    if [[ -z "$1" ]]; then
      issue_number=$(_select_note_with_fzf)
      [[ -z "$issue_number" ]] && exit 0
      open_note "$issue_number"
    else
      open_note "$@"
    fi
    ;;
  edit)
    shift
    if [[ -z "$1" ]]; then
      issue_number=$(_select_note_with_fzf)
      [[ -z "$issue_number" ]] && exit 0
      edit_note "$issue_number"
    else
      edit_note "$@"
    fi
    ;;
  comment)
    shift
    if [[ -z "$1" ]]; then
      issue_number=$(_select_note_with_fzf)
      [[ -z "$issue_number" ]] && exit 0
      comment_note "$issue_number"
    else
      comment_note "$@"
    fi
    ;;
  delete)
    shift
    if [[ -z "$1" ]]; then
      issue_number=$(_select_note_with_fzf)
      [[ -z "$issue_number" ]] && exit 0
      delete_note "$issue_number"
    else
      delete_note "$@"
    fi
    ;;
  *)
    echo "Usage: note <command> [arguments]"
    echo ""
    echo "Commands:"
    echo "  create                Create a new note (opens editor)."
    echo "  list                  List all open notes."
    echo "  view [<issue_number>] View a specific note. If no number is given, a selector will appear."
    echo "  open [<issue_number>] Open a note in your web browser. If no number is given, a selector will appear."
    echo "  edit [<issue_number>] Edit a specific note. If no number is given, a selector will appear."
    echo "  comment [<issue_number>] Add a comment to a specific note. If no number is given, a selector will appear."
    echo "  delete [<issue_number>] Close a specific note. If no number is given, a selector will appear."
    ;;
esac
