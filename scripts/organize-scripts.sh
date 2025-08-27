#!/bin/bash

# Script to organize scripts into individual directories with README templates
# This script will:
# 1. Find all script files in subdirectories
# 2. Create a new directory for each script
# 3. Move the script into its new directory
# 4. Generate a template README for each script
#
# Usage: ./organize-scripts.sh [--dry-run]

set -euo pipefail

# Parse command line arguments
DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

SCRIPTS_ROOT="/home/patrick/repo/incubator/dotfiles/scripts"
BACKUP_DIR="$SCRIPTS_ROOT/.backup-$(date +%Y%m%d_%H%M%S)"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper function for trimming whitespace
trim() {
    sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to create README template
create_readme_template() {
    local script_path="$1"
    local script_name="$2"
    local script_dir="$3"
    local script_ext="$4"
    
    local readme_path="$script_dir/README.md"
    
    # Determine language for syntax highlighting
    local language=""
    case "$script_ext" in
        "sh") language="bash" ;;
        "py") language="python" ;;
        "js") language="javascript" ;;
        "lua") language="lua" ;;
        "exs") language="elixir" ;;
        *) language="bash" ;;
    esac
    
    # Try to extract first comment block as description
    local description=""
    if [[ -f "$script_path" ]]; then
        case "$script_ext" in
            "sh"|"py"|"pl")
                description=$(head -20 "$script_path" | grep -E "^#[^!]" | head -5 | sed 's/^# *//' | tr '\n' ' ' | sed 's/  */ /g' | trim || echo "")
                ;;
            "js")
                description=$(head -20 "$script_path" | grep -E "^//" | head -5 | sed 's/^\/\/ *//' | tr '\n' ' ' | sed 's/  */ /g' | trim || echo "")
                ;;
        esac
    fi
    
    if [[ -z "$description" ]]; then
        description="A script for automated tasks."
    fi
    
    cat > "$readme_path" << EOF
# ${script_name}

## Description
${description}

## Usage
\`\`\`${language}
./${script_name}
\`\`\`

## Requirements
- Script interpreter for ${language}
- Appropriate permissions (chmod +x ${script_name})

## Notes
- Originally located in: \`${script_path}\`
- Created by script organization automation

## Author
Generated template - please update with actual author information
EOF
    
    print_status "$GREEN" "  ✓ Created README.md"
}

# Function to process a single script file
process_script() {
    local script_path="$1"
    local relative_path="${script_path#$SCRIPTS_ROOT/}"
    
    # Skip if it's in a subdirectory that already has its own structure
    if [[ "$relative_path" == *"_"* ]] && [[ -d "$(dirname "$script_path")" ]]; then
        local parent_dir=$(basename "$(dirname "$script_path")")
        if [[ "$parent_dir" == "_"* ]]; then
            print_status "$YELLOW" "Skipping $relative_path (already in organized structure)"
            return
        fi
    fi
    
    # Extract script name and extension
    local script_full_name=$(basename "$script_path")
    local script_name="${script_full_name%.*}"
    local script_ext="${script_full_name##*.}"
    
    # Skip if already processed or if it's this script itself
    if [[ "$script_name" == "organize-scripts" ]]; then
        print_status "$YELLOW" "Skipping organize-scripts.sh (this script)"
        return
    fi
    
    # Determine target directory (flat structure under scripts/)
    local target_dir="$SCRIPTS_ROOT/$script_name"
    
    print_status "$BLUE" "Processing: $relative_path"
    
    # Create target directory
    if [[ ! -d "$target_dir" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            print_status "$BLUE" "  [DRY RUN] Would create directory: $script_name/"
        else
            mkdir -p "$target_dir"
            print_status "$GREEN" "  ✓ Created directory: $script_name/"
        fi
    fi
    
    # Move script to target directory
    local new_script_path="$target_dir/$script_full_name"
    if [[ "$script_path" != "$new_script_path" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            print_status "$BLUE" "  [DRY RUN] Would move script to: $script_name/$script_full_name"
        else
            mv "$script_path" "$new_script_path"
            print_status "$GREEN" "  ✓ Moved script to: $script_name/$script_full_name"
        fi
    fi
    
    # Create README if it doesn't exist
    local readme_path="$target_dir/README.md"
    if [[ "$DRY_RUN" == "true" ]] || [[ ! -f "$readme_path" ]]; then
        if [[ "$DRY_RUN" == "true" ]]; then
            print_status "$BLUE" "  [DRY RUN] Would create README.md"
        else
            create_readme_template "$script_path" "$script_full_name" "$target_dir" "$script_ext"
        fi
    else
        print_status "$YELLOW" "  - README.md already exists, skipping"
    fi
    
    # Make script executable
    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "$BLUE" "  [DRY RUN] Would make script executable"
    else
        chmod +x "$new_script_path"
        print_status "$GREEN" "  ✓ Made script executable"
    fi
    
    echo
}

# Function to create backup
create_backup() {
    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "$BLUE" "[DRY RUN] Would create backup at: $BACKUP_DIR"
        echo
        return
    fi
    
    print_status "$BLUE" "Creating backup at: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    
    # Find all script files and copy them to backup
    find "$SCRIPTS_ROOT" -type f \( -name "*.sh" -o -name "*.py" -o -name "*.js" -o -name "*.lua" -o -name "*.exs" -o -name "*.pl" -o -name "*.rb" \) ! -path "$BACKUP_DIR/*" ! -name "organize-scripts.sh" | while read -r file; do
        local rel_path="${file#$SCRIPTS_ROOT/}"
        local backup_file="$BACKUP_DIR/$rel_path"
        mkdir -p "$(dirname "$backup_file")"
        cp "$file" "$backup_file"
    done
    
    print_status "$GREEN" "✓ Backup created successfully"
    echo
}

# Main execution
main() {
    print_status "$BLUE" "=== Script Organization Tool ==="
    if [[ "$DRY_RUN" == "true" ]]; then
        print_status "$YELLOW" "*** DRY RUN MODE - No changes will be made ***"
    fi
    print_status "$BLUE" "This will organize all scripts into individual directories with README templates"
    echo
    
    # Check if we're in the right directory
    if [[ ! -d "$SCRIPTS_ROOT" ]]; then
        print_status "$RED" "Error: Scripts directory not found at $SCRIPTS_ROOT"
        exit 1
    fi
    
    cd "$SCRIPTS_ROOT"
    
    # Create backup
    create_backup
    
    # Find and process all script files
    print_status "$BLUE" "Processing script files..."
    echo
    
    # Process each script type
    local file_patterns=("*.sh" "*.py" "*.js" "*.lua" "*.exs" "*.pl" "*.rb")
    local total_processed=0
    
    for pattern in "${file_patterns[@]}"; do
        print_status "$BLUE" "Processing pattern: $pattern"
        local pattern_count=0
        while IFS= read -r -d '' script_path; do
            process_script "$script_path" || {
                print_status "$RED" "Error processing $script_path, continuing..."
                continue
            }
            total_processed=$((total_processed + 1))
            pattern_count=$((pattern_count + 1))
        done < <(find "$SCRIPTS_ROOT" -type f -name "$pattern" ! -path "*/.*" ! -name "organize-scripts.sh" -print0)
        print_status "$BLUE" "Completed pattern: $pattern (processed: $pattern_count, total so far: $total_processed)"
    done
    
    # Summary
    echo
    print_status "$GREEN" "=== Organization Complete ==="
    print_status "$GREEN" "✓ Processed $total_processed script files"
    print_status "$GREEN" "✓ Created individual directories with README templates"
    print_status "$GREEN" "✓ Backup created at: $BACKUP_DIR"
    echo
    print_status "$BLUE" "You can now find each script in its own directory with documentation."
    print_status "$BLUE" "Remember to update the README files with more specific information about each script."
}

# Run main function
main "$@"
