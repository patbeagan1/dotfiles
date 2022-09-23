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

replace_known_abbreviations() {
  sed 's/U\.S\./U-S-/ig' |
    sed 's/U\.S\.A\./U-S-A-/ig' |
    sed 's/i\.e\./i-e-/g' |
    sed 's/_i\.e_\./i-e-/g' |
    sed 's/e\.g\./e-g-/g'
}

replace_quoted_punctuation() {
  sed 's/\."/"\./g' |
    sed 's/\,"/"\,/g' |
    sed 's/\?"/"\?/g' |
    sed 's/\!"/"\!/g' |
    sed 's/\;"/"\;/g' |
    sed 's/\:"/"\:/g' |
    sed "s/\.'/'\./g" |
    sed "s/\,'/'\,/g" |
    sed "s/\?'/'\?/g" |
    sed "s/\:'/'\:/g" |
    sed "s/\;'/'\;/g" |
    sed "s/\!'/'\!/g"
}

replace_parenthesized_punctuation() {
  sed 's/\.)/)\./g' |
    sed 's/\!)/)\!/g' |
    sed 's/\,)/)\,/g'
}

transliterate_for_font_compatibility() {
  sed 's/“/"/g' |
    sed 's/”/"/g' |
    sed "s/’/\'/g" |
    sed "s/‘/\'/g"
}

replace_punctuation() {
  sed 's/,/,\n /g' |
    sed 's/;/;\n /g' |
    sed 's/:/:\n /g' |
    sed 's/\./\.\n\n/g' |
    sed 's/\?/\?\n\n/g' |
    sed 's/\!/\!\n\n/g' |
    sed 's/—/--/g'
}

replace_conjunction() {
  sed 's/ and /\n  and /g' |
    sed 's/ AND /\n  AND /g' |
    sed 's/ or /\n  or /g' |
    sed 's/ OR /\n  OR /g'
}

replace_double_spaces() {
  sed 's/  / /g'
}

reduce_newlines() {
  tr '\n' '\r' |
    sed 's/\r\r/NEWLINE-MAGIC-9182/g' |
    sed 's/NEWLINE-MAGIC-9182NEWLINE-MAGIC-9182/\n\n/g' |
    sed 's/NEWLINE-MAGIC-9182/ /g'
}

increase_newlines() {
  tr '\n' '\r' |
    sed 's/\r/\r\r/g' |
    tr '\r' '\n'
}

reduce_newlines_after_conjunction() {
  tr '\n' '\r' |
    sed -E 's/\r[ ]*\r[ ]*and/\r  and/g' |
    sed -E 's/\r[ ]*\r[ ]*or/\r  or/g' |
    tr '\r' '\n'
}

save_generic_abbreviations() {
  sed -E 's/(\.)([^ ])/DOT-MAGIC-9876\2/g'
}

finalize_generic_abbrevations() {
  sed -E 's/DOT-MAGIC-9876/\./g'
}

format_core() {
  transliterate_for_font_compatibility |
    replace_double_spaces |
    replace_known_abbreviations |
    replace_quoted_punctuation |
    replace_parenthesized_punctuation |
    save_generic_abbreviations |
    replace_punctuation |
    finalize_generic_abbrevations
}

simplify-prose-legal() {
  cat "$1" |
    remove_leading_whitespace |
    increase_newlines |
    tr "\n" " " |
    format_core |
    replace_conjunction |
    reduce_newlines_after_conjunction |
    awk '{print ++count "\t" "| " $0}'
}

simplify-prose() {
  cat "$1" |
    remove_leading_whitespace |
    reduce_newlines |
    tr "\n" "\r" |
    sed 's/\r\r/\n--------\n\n /g' |
    format_core |
    awk '/--------/ {print ++count, $0} !/--------/ {print}'
}

if [ ! $# -eq 2 ]; then
  help
elif [ "$1" = "-l" ]; then
  shift
  simplify-prose-legal "$@" || help
elif [ "$1" = "-p" ]; then
  shift
  simplify-prose "$@" || help
else
  help
fi
trackusage.sh "$0"
