#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

set -euo pipefail

scriptname="$(basename "$0")"
help() {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help]

Adds copyright header to all Python scripts in the ./scripts directory.
The copyright header will be inserted after the shebang line in each .py file.

The copyright header added is:
# (c) 2022 Pat Beagan: MIT License

This script modifies files in place using sed.
"
    exit $error_code
}

main() {

    emulate -L zsh
    zmodload zsh/zutil || return 1

    local help
    zparseopts -D -F -K -- \
        {h,-help}=help ||
        return 1

    if (($#help)); then help; fi

apply-copyright-bash () {
	find ./scripts -name "*.py" -type f -exec sed -i '' 's/^#!\(.*\)/#!\1\n# \(c\) 2022 Pat Beagan: MIT License/' {} \;
}

    apply-copyright-bash "$@" || help
}

main "$@" || help
trackusage.sh "$0"
