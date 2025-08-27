#!/bin/bash

# Check if file names are provided as arguments
if [ $# -gt 0 ]; then
    # Use the provided file names
    files=("$@")
else
    # Use the files in the current directory
    files=(*)
fi

count=${#files[@]}
index=0

# Function to display the current file
display_file() {
    clear
    chafa "${files[$index]}"
    # Move the cursor up to the top of the display
    tput cup 0 0
    # Write the informational line
    echo "Viewing file $((index + 1))/$count: ${files[$index]}"
    # Move the cursor back down to avoid overwriting the line
    tput cup 1 0
}

# Trap the exit signal to clear the screen upon exit
trap 'clear' EXIT

# Display the first file
display_file

# Listen for key-up events and navigate through the files
while true; do
    read -rsn1 input
    if [[ $input == $'\x1B' ]]; then
        read -rsn2 input
        if [[ $input == '[A' ]] || [[ $input == '[D' ]]; then
            # Up arrow or left arrow: go to the previous file
            ((index--))
            if ((index < 0)); then index=$((count - 1)); fi
            display_file
        elif [[ $input == '[B' ]] || [[ $input == '[C' ]]; then
            # Down arrow or right arrow: go to the next file
            ((index++))
            if ((index >= count)); then index=0; fi
            display_file
        fi
    fi
done

