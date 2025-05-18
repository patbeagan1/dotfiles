-- games/dead_by_daylight.lua
local DBDEvents = {}

function DBDEvents.get_events()
    return {
        {0, "Welcome to Dead by Daylight! Match has started."},
        {60, "1-minute mark. Survivors should repair generators."},
        {240, "4-minute mark. Killers should focus on tracking survivors."},
        {600, "10-minute mark. Late-game hatch spawns soon. Prepare for endgame!"},
        {900, "15-minute mark. Match is nearing its end. Secure the escape or the hunt!"}
    }
end

return DBDEvents
