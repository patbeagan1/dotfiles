-- games/overwatch.lua
local OverwatchEvents = {}

function OverwatchEvents.get_events()
    return {
        {0, "Welcome to Overwatch! Prepare for battle."},
        {15, "15 seconds until the doors open. Position yourself!"},
        {60, "1-minute mark. First team fights are critical!"},
        {180, "3-minute mark. Ultimates should be ready soon."},
        {300, "5-minute mark. Overtime is likely. Focus on the objective!"}
    }
end

return OverwatchEvents
