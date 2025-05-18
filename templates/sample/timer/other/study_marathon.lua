-- games/study_marathon.lua
local StudyMarathonEvents = {}

function StudyMarathonEvents.get_events()
    local events = {}
    local study_duration = 50 * 60 -- 50 minutes
    local short_break = 10 * 60 -- 10 minutes
    local long_break = 30 * 60 -- 30 minutes
    local cycles = 6 -- Total study sessions (3 hours total)

    local current_time = 0
    for cycle = 1, cycles do
        table.insert(events, {current_time, "Start a 50-minute focused study session."})
        current_time = current_time + study_duration

        if cycle % 2 == 0 then
            table.insert(events, {current_time, "Take a 30-minute long break. Recharge!"})
            current_time = current_time + long_break
        else
            table.insert(events, {current_time, "Take a 10-minute short break."})
            current_time = current_time + short_break
        end
    end

    table.insert(events, {current_time, "Study marathon complete. Excellent work!"})
    return events
end

return StudyMarathonEvents
