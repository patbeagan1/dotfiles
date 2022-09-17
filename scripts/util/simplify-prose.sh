#!/usr/bin/env zsh

set -euo pipefail
IFS=$'\n\t'

help() {
    error_code=$?
    echo "
Helps to break up large blocks of text by putting common punctuation on different lines.
  Paragraphs are shown with horizontal rules,
  Sentences are shown by new paragraphs,
  Commas are shown as new lines that are indented.

This helps when reading thick prose from before 1900, 
  because it allows you to more easily filter out the sentences that are irrelevant, 
  and double back to the parts that have become relveant again, once a stack of clauses resolves.
"
    if [[ ! $error_code -eq 0 ]]; then echo "Err: $error_code"; fi
}

preprocess() {
    # removes leading whitespace
    sed 's/^[ ]*\(.*$\)/\1/' |
        tr '\n' '\r' |
        sed 's/\r\r/NEWLINE-MAGIC-9182/g' |
        sed 's/NEWLINE-MAGIC-9182NEWLINE-MAGIC-9182/\n\n/g' |
        sed 's/NEWLINE-MAGIC-9182/ /g'
}

simplify-prose() {
    cat "$1" |
        preprocess |
        tr "\n" "\r" |
        sed 's/\r\r/\n--------\n\n /g' |
        sed 's/  / /g' |
        
        sed 's/i\.e\./i-e-/g' |
        sed 's/_i\.e_\./i-e-/g' |
        sed 's/e\.g\./e-g-/g' |

        sed 's/\."/"\./g' |
        sed 's/\.”/”\./g' |
        sed 's/\,"/"\,/g' |
        sed 's/\,”/”\,/g' |
        
        sed 's/,/,\n /g' |
        sed 's/;/;\n /g' |
        sed 's/\./\.\n\n/g' |
        sed 's/\?/\?\n\n/g' |
        sed 's/\!/\!\n\n/g' |
        
        awk '/--------/ {print ++count, $0} !/--------/ {print}'
}

simplify-prose "$@" || help
trackusage.sh "$0"
