set_holiday_prompt() {
  # Get the current month, day, and year
  local month_day=$(date +%m-%d)
  local year=$(date +%Y)

  # Simple algorithm to approximate Easter date (not accurate beyond 2099)
  local easter_month=$(( (19 * (year % 19) + 15) % 30 + 4 ))
  local easter_day=$(( easter_month / 31 + 1 ))
  easter_month=$(( easter_month % 31 + 3 ))

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
    11-$(date -d "$year-11-01 +3 thursday" +%m-%d)) holiday_prompt="%{$fg[yellow]%}🦃 $holiday_prompt%{$fg[yellow]%}🦃" ;;  # Thanksgiving
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
