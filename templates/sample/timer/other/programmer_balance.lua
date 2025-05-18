-- games/programmer_balance.lua
local ProgrammerBalanceEvents = {}

function ProgrammerBalanceEvents.get_events()
    local events = {}
    local coding_duration = 45 * 60 -- 45 minutes
    local slack_duration = 10 * 60 -- 10 minutes
    local short_break = 5 * 60 -- 5 minutes
    local total_cycles = 4 -- Number of coding-slack cycles before a long break
    local long_break = 15 * 60 -- 15 minutes

    local current_time = 0
    for cycle = 1, total_cycles do
        -- Add focused coding period
        table.insert(events, {current_time, "Focus on coding for 45 minutes. Minimize distractions!"})
        current_time = current_time + coding_duration

        -- Add Slack-checking period
        table.insert(events, {current_time, "Take 10 minutes to check Slack or respond to messages."})
        current_time = current_time + slack_duration

        -- Add short break, except after the last cycle
        if cycle < total_cycles then
            table.insert(events, {current_time, "Take a 5-minute break. Stretch and relax!"})
            current_time = current_time + short_break
        else
            table.insert(events, {current_time, "Take a 15-minute long break. Great job staying balanced!"})
            current_time = current_time + long_break
        end
    end

    return events
end

return ProgrammerBalanceEvents
