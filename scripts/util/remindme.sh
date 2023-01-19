#!/usr/bin/env zsh

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

remindme () {
	osascript - "$1" <<END
on run a
tell app "Reminders"
tell list "Reminders" of default account
make new reminder with properties {name:item 1 of a}
end
end
end
END
}

    remindme "$@" || help
}

main "$@" || help
trackusage.sh "$0"
