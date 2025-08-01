#!/usr/bin/env bash
# (c) 2022 Pat Beagan: MIT License

set -euo pipefail
IFS=$'\n\t'

scriptname="$(basename "$0")"

# Standard error handling
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Standard help function
help() {
    error_code=$?
    cat << EOF
Usage: $scriptname [-h|--help] [options] <arguments>

Description of what this script does.

Options:
  -h, --help    Show this help message
  [other options]

Arguments:
  [description of arguments]

Examples:
  $scriptname example1
  $scriptname example2

EOF
    exit $error_code
}

# Main function
main() {
    # Argument parsing
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                help
                ;;
            *)
                # Handle other arguments
                break
                ;;
        esac
        shift
    done

    # Validate required arguments
    if [[ $# -lt 1 ]]; then
        error_exit "Missing required argument"
    fi

    # Main logic here
    echo "Processing: $1"
}

# Execute main function with all arguments
main "$@" || help

# Track usage if trackusage.sh exists
if command -v trackusage.sh >/dev/null 2>&1; then
    trackusage.sh "$0"
fi 