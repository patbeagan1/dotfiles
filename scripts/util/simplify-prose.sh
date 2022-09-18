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

Required mode flag
  -l: legal mode
  -p: prose mode

Errs:
  1: generic
  2: missing mode flag
"
  if [[ ! $error_code -eq 0 ]]; then echo "Err: $error_code"; fi
}

remove_leading_whitespace() {
  # removes leading whitespace
  sed 's/^[ ]*\(.*$\)/\1/'
}

replace_abbreviations() {
  sed 's/i\.e\./i-e-/g' |
    sed 's/_i\.e_\./i-e-/g' |
    sed 's/e\.g\./e-g-/g'
}

replace_quoted_punctuation() {
  sed 's/\."/"\./g' |
    sed 's/\.”/”\./g' |
    sed 's/\,"/"\,/g' |
    sed 's/\,”/”\,/g'
}

replace_punctuation() {
  sed 's/,/,\n /g' |
    sed 's/;/;\n /g' |
    sed 's/\./\.\n\n/g' |
    sed 's/\?/\?\n\n/g' |
    sed 's/\!/\!\n\n/g'
}

replace_double_spaces() {
  sed 's/  / /g'
}

format_core() {
  replace_double_spaces |
    replace_abbreviations |
    replace_quoted_punctuation |
    replace_punctuation
}

simplify-prose-legal() {
  cat "$1" |
    remove_leading_whitespace |
    tr "\n" " " |
    format_core |
    awk '{print ++count "\t" "| " $0}'
}

simplify-prose() {
  cat "$1" |
    remove_leading_whitespace |
    tr '\n' '\r' |
    sed 's/\r\r/NEWLINE-MAGIC-9182/g' |
    sed 's/NEWLINE-MAGIC-9182NEWLINE-MAGIC-9182/\n\n/g' |
    sed 's/NEWLINE-MAGIC-9182/ /g' |
    tr "\n" "\r" |
    sed 's/\r\r/\n--------\n\n /g' |
    format_core |
    awk '/--------/ {print ++count, $0} !/--------/ {print}'
}

if [ "$1" = "-l" ]; then
  shift
  simplify-prose-legal "$@" || help
elif [ "$1" = "-p" ]; then
  shift
  simplify-prose "$@" || help
else
  true
  help
fi
trackusage.sh "$0"
