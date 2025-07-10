#!/usr/bin/env zsh

set -euo pipefail

scriptname="$(basename "$0")"
help() {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help] <reminder_text>

Creates a reminder in the macOS Reminders app using AppleScript.
Adds the reminder to the default 'Reminders' list.

Arguments:
  reminder_text    Text content for the reminder

Features:
  - Uses macOS Reminders app
  - Adds to default 'Reminders' list
  - Works with AppleScript automation

Examples:
  $scriptname 'Call mom tomorrow'
  $scriptname 'Buy groceries on Friday'
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
