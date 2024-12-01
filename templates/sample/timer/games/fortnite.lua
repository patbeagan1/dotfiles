-- games/fortnite.lua
local FortniteEvents = {}

function FortniteEvents.get_events()
    return {
        {0, "Welcome to Fortnite! Prepare to drop into the island."},
        {20, "20 seconds elapsed. Decide where to drop!"},
        {60, "1-minute mark. Gather resources and gear up."},
        {240, "4-minute mark. The first storm circle is shrinking. Move to safety!"},
        {600, "10-minute mark. Mid-game skirmishes are likely. Stay alert."},
        {1200, "20-minute mark. Endgame is here. Build, fight, and survive!"}
    }
end

return FortniteEvents
