-- games/rocket_league.lua
local RocketLeagueEvents = {}

function RocketLeagueEvents.get_events()
    return {
        {0, "Welcome to Rocket League! Kickoff is about to start."},
        {300, "5-minute mark. Regulation time is over. Overtime may start."},
        {360, "6-minute mark. Sudden death overtime is in progress."},
        {600, "10-minute mark. Game is reaching its conclusion!"}
    }
end

return RocketLeagueEvents
