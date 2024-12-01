-- games/hots.lua
local HotsEvents = {}

function HotsEvents.get_events()
    return {
        {0, "Welcome to the Nexus! Prepare to fight."},
        {60, "1-minute mark. First objectives will spawn soon."},
        {180, "3-minute mark. First battleground objective is active! Prioritize it."},
        {300, "5-minute mark. Mercenary camps are respawning. Capture them!"},
        {600, "10-minute mark. Mid-game objectives are spawning soon."},
        {1200, "20-minute mark. Late-game objectives are critical to victory. Stay grouped!"}
    }
end

return HotsEvents
