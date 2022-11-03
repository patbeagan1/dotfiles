#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

set -euo pipefail

scriptname="$0"
help() {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help]

No help message yet
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
	find ./scripts -name "*.sh" -type f -exec sed -i '' 's/^#!\(.*\)/#!\1\n# \(c\) 2022 Pat Beagan: MIT License/' {} \;
}

    apply-copyright-bash "$@" || help
}

main "$@" || help
trackusage.sh "$0"
