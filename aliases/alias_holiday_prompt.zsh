set_holiday_prompt() {
  # Get the current month, day, and year
  local month_day=$(date +%m-%d)
  local year=$(date +%Y)

  # Simple algorithm to approximate Easter date (not accurate beyond 2099)
  local easter_month=$(( (19 * (year % 19) + 15) % 30 + 4 ))
  local easter_day=$(( easter_month / 31 + 1 ))
  easter_month=$(( easter_month % 31 + 3 ))

  # 4th Thursday of November (Thanksgiving) — portable across GNU and BSD date
  local thanksgiving_md=""
  local nov1_dow
  if nov1_dow=$(date -d "$year-11-01" +%u 2>/dev/null); then
    # GNU date: %u 1=Mon .. 7=Sun
    local first_thu=$(( 1 + (4 - nov1_dow + 7) % 7 ))
    thanksgiving_md=$(printf '11-%02d' $(( first_thu + 21 )))
  elif nov1_dow=$(date -j -f "%Y-%m-%d" "$year-11-01" +%u 2>/dev/null); then
    # BSD date (macOS)
    local first_thu=$(( 1 + (4 - nov1_dow + 7) % 7 ))
    thanksgiving_md=$(printf '11-%02d' $(( first_thu + 21 )))
  fi

  # Start with the original prompt
  local holiday_prompt="$PROMPT"

  # Add holiday decorations based on the current date
  case $month_day in
    12-25) holiday_prompt="%{$fg[red]%}🎄 $holiday_prompt%{$fg[red]%}🎄" ;;  # Christmas
    10-31) holiday_prompt="%{$fg[orange]%}🎃 $holiday_prompt%{$fg[orange]%}🎃" ;;  # Halloween
    01-01) holiday_prompt="%{$fg[brightcyan]%}🎉 $holiday_prompt%{$fg[brightcyan]%}🎉" ;;  # New Year
    02-14) holiday_prompt="%{$fg[red]%}❤️ $holiday_prompt%{$fg[red]%}❤️" ;;  # Valentine's Day
    07-04) holiday_prompt="%{$fg[blue]%}🇺🇸 $holiday_prompt%{$fg[red]%}🇺🇸" ;;  # Independence Day
    03-17) holiday_prompt="%{$fg[green]%}🍀 $holiday_prompt%{$fg[green]%}🍀" ;;  # St. Patrick's Day
    "$easter_month-$easter_day") holiday_prompt="%{$fg[magenta]%}🐣 $holiday_prompt%{$fg[magenta]%}🐣" ;;  # Easter
    ${thanksgiving_md}) holiday_prompt="%{$fg[yellow]%}🦃 $holiday_prompt%{$fg[yellow]%}🦃" ;;  # Thanksgiving
  esac

  # Set the new prompt
  PROMPT="$holiday_prompt"
}

set_holiday_prompt


function holiday_st_patricks () {
  echo "
🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀
🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀
🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀
🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀
🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀
🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀
🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀
🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀
🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀
🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀🌈🍀🍺🍀
🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀🍀
"
}
