#!/usr/bin/env bash
# Interactively find biggest directories using df, du, and fzf.

set -euo pipefail

# Step 1: Select a filesystem or your home directory using df and fzf

# Get the list of filesystems from df
df_list=$(df -P -h)

# Add the user's home directory as an extra option
home_dir="${HOME}"
home_label="HOME          $home_dir"

# Combine home directory option and df output for fzf
fzf_input=$(printf "%s\n%s\n" "$home_label" "$df_list")

df_line=$(echo "$fzf_input" | fzf --header "Select a filesystem or your home directory to analyze" --tac)
if [ -z "$df_line" ]; then
    exit 0
fi

# Extract the mount point from the selected line
# This handles mount points with spaces
current_dir=$(echo "$df_line" | awk '{ $1=$2=$3=$4=$5=""; print $0 }' | sed -e 's/^[[:space:]]*//')

# Step 2: Interactively explore directories with du and fzf
while true; do
    # Ensure current_dir is an absolute path
    current_dir=$(cd "$current_dir" && pwd)
    echo "current_dir: $current_dir"

    header="Disk usage for $current_dir (sorted by size)"
    
    # Generate the list for fzf. Use 'ls -A' to list files and 'du' for directories.
    # Add ".." to go up, unless we are at the root of the selected mount.
    
    # List directories with sizes (non-recursive, only one level deep)
    dir_list=$(find "$current_dir" -mindepth 1 -maxdepth 1 -type d -exec du -sh {} + 2>/dev/null)
    echo "$dir_list"
    
    # List files (without sizes for now to keep it simple)
    file_list=$(ls -A -p "$current_dir" | grep -v /)
    echo "$file_list"

    # Combine them, directories first, then files
    combined_list="$dir_list"
    if [ -n "$file_list" ]; then
        combined_list+=$'\n'
        combined_list+=$(echo "$file_list" | awk '{print "--         " $0}')
    fi

    # Add '..' to go up a directory, if not at the root
    if [ "$current_dir" != "/" ]; then
        up_entry="--         .."
        fzf_input="$up_entry\n$combined_list"
    else
        fzf_input="$combined_list"
    fi

    # Show fzf and get user selection, sorted by human-readable size
    choice=$(echo -e "$fzf_input" | sort -rh | fzf --header="$header")

    # Exit if fzf was cancelled
    if [ -z "$choice" ]; then
        exit 0
    fi

    # Extract the path part of the choice, handling spaces
    path_part=$(echo "$choice" | awk '{ $1=""; print $0 }' | sed -e 's/^[[:space:]]*//')

    if [ "$path_part" = ".." ]; then
        # Go up one directory
        current_dir=$(dirname "$current_dir")
    else
        # Handle the selected item
        selected_path="$path_part"
        
        # If the path from du is relative, make it absolute. 
        # du -sh /some/path/*/ gives absolute paths, so this might not be needed, but it's safer.
        if [[ "$selected_path" != /* ]]; then
            selected_path="$current_dir/$selected_path"
        fi

        # Remove trailing slash if it exists
        selected_path=${selected_path%/}

        if [ -d "$selected_path" ]; then
            current_dir="$selected_path"
        elif [ -f "$selected_path" ]; then
            # It's a file, we can't go into it.
            echo "'$selected_path' is a file. Press enter to continue exploring '$current_dir'."
            read -r
        else
            # Should not happen often
            echo "Selection '$selected_path' is not a directory or a regular file. Press enter to continue."
            read -r
        fi
    fi
done
