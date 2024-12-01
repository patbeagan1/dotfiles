-- games/starcraft.lua
local StarCraftEvents = {}

function StarCraftEvents.get_events()
    return {
        {0, "Welcome to StarCraft II! Prepare to build your base."},
        {30, "30 seconds elapsed. Begin scouting for enemy positions."},
        {60, "1 minute elapsed. Build your first barracks, gateway, or spawning pool."},
        {120, "2-minute mark. Expand your base or prepare for early aggression!"},
        {300, "5-minute mark. Mid-game engagements may start soon. Stay alert!"},
        {600, "10-minute mark. Late-game units and strategies are in play."}
    }
end

return StarCraftEvents
