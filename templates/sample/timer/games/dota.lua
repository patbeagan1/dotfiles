-- games/dota.lua
local DotaEvents = {}

function DotaEvents.get_events()
    local events = {
        {0, "Welcome to Dota 2! Prepare for battle."},
        {10, "10 seconds have passed. The battle begins shortly!"},
        {60, "1-minute mark. Water runes are available. Check runes!"},
        {120, "2-minute mark. Water runes are available again. Check midlane!"},
        {300, "5-minute mark. Bounty runes are available, and siege creeps will spawn."},
        {420, "7-minute mark. Power runes will spawn soon."},
        {1200, "20-minute mark. Tormentors will spawn soon! Prioritize objectives."},
        {3600, "1-hour mark. Giant's Ring and other tier 5 items may drop soon!"}
    }

    -- Day/Night cycle
    for i = 1, 12 do
        local time = i * 300
        if i % 2 == 1 then
            table.insert(events, {time, "Daytime has begun. Adjust your strategies accordingly."})
        else
            table.insert(events, {time, "Nighttime has begun. Vision is reduced, be cautious!"})
        end
    end

    return events
end

return DotaEvents
