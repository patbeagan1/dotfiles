#!/usr/bin/env zsh

# fe.zsh - A Zsh file explorer using fzf, chafa, and bat.
# All code is in a single file for easy portability and use.

#--- Preview Function ---
# This function generates the content for fzf's preview window.
# It checks the file type and uses the appropriate tool for a rich preview.
preview_file() {
    local file_path="$1"

    # Check if the file exists.
    if [[ ! -e "$file_path" ]]; then
        echo "File not found: $file_path"
        return 1
    fi

    # Use 'file' to determine the MIME type.
    local mime_type=$(file --mime-type -b "$file_path")

    # Handle different file types based on MIME type.
    case "$mime_type" in
        # Image types
        image/*)
            # Use 'chafa' for image previews.
            if command -v chafa &> /dev/null; then
                chafa -s 1 -c 256 "$file_path"
            else
                echo "chafa not found. Please install it for image previews."
                echo "File: $file_path"
            fi
            ;;

        # Text files (including code, scripts, etc.)
        text/* | application/json | application/javascript | application/x-shellscript | application/xml)
            # Use 'bat' for syntax highlighting if available, otherwise fall back to 'cat'.
            if command -v bat &> /dev/null; then
                bat --style=full --color=always "$file_path"
            else
                cat "$file_path"
            fi
            ;;

        # PDF documents
        application/pdf)
            echo "PDF file: $file_path"
            echo ""
            echo "--- Text Preview (first page) ---"
            if command -v pdftotext &> /dev/null; then
                pdftotext -q -l 1 "$file_path" - | head -n 50
            else
                echo "pdftotext not found. Please install it for PDF previews."
            fi
            ;;

        # Archive files (zip, tar, etc.)
        application/zip | application/x-tar | application/gzip)
            echo "Archive file: $file_path"
            echo ""
            echo "--- Contents ---"
            if [[ "$mime_type" == "application/zip" ]]; then
                if command -v unzip &> /dev/null; then
                    unzip -l "$file_path" | head -n 20
                else
                    echo "unzip not found."
                fi
            else # Assume tar/gzip
                if command -v tar &> /dev/null; then
                    tar -tvf "$file_path" | head -n 20
                else
                    echo "tar not found."
                fi
            fi
            ;;

        # Directories
        inode/directory)
            # List directory contents with 'ls'.
            ls -lAh --color=always "$file_path"
            ;;

        # All other file types
        *)
            echo "Unknown or binary file."
            echo "MIME type: $mime_type"
            ;;
    esac
}

#--- Main Explorer Function ---
fe() {
    # Check for necessary commands.
    if ! command -v fzf &> /dev/null; then
        echo "Error: fzf is not installed. Please install fzf to use this script."
        return 1
    fi

    # Use a subshell to avoid changing the user's current directory directly.
    # The 'cd' command within the fzf 'enter' binding will manage directory changes.
    (
        local start_dir="${1:-.}"
        cd "$start_dir" || return

        while true; do
            # The fzf command with all its options.
            local selected_path=$(
                find -L . -maxdepth 4 -print0 | fzf \
                --ansi \
                --preview-window=right:50% \
                --preview="preview_file {}" \
                --layout=reverse \
                --height=100% \
                --bind='ctrl-o:execute(xdg-open {} &> /dev/null &)' \
                --bind='enter:execute(
                    if [[ -d {} ]]; then
                        cd {}
                        # Break the while loop to re-run fzf with the new directory.
                        return
                    else
                        xdg-open {}
                    fi
                )' \
                --color=bg+:#373b41,bg:#202020,fg:#e5e5e5,hl:#5e81ac,fg+:#ffffff,hl+:#5e81ac \
                --border=sharp \
                --header="Navigate with arrows, ENTER to open/change dir, CTRL-O to open in app"
            )
            # Exit if the user cancels fzf.
            if [[ -z "$selected_path" ]]; then
                break
            fi
        done
    )
}

# Run the function with arguments passed to the script.
fe "$@"
