-- games/league.lua
local LeagueEvents = {}

function LeagueEvents.get_events()
    return {
        {0, "Welcome to Summoner's Rift! Prepare for the match."},
        {90, "Minions have spawned! Get ready for the lanes."},
        {300, "5-minute mark. Jungle camps have respawned!"},
        {600, "10-minute mark. Rift Herald is available."},
        {1200, "20-minute mark. Baron Nashor is available."},
        {1800, "30-minute mark. Elder Dragon is now available. Secure objectives!"}
    }
end

return LeagueEvents
