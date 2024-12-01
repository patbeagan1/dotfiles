-- games/tft.lua
local TFTEvents = {}

function TFTEvents.get_events()
    return {
        {0, "Welcome to Teamfight Tactics! Plan your strategy."},
        {30, "30 seconds until the first carousel. Choose your item!"},
        {90, "1 minute 30 seconds. First PvE round is ending. Prepare to buy champions."},
        {300, "5-minute mark. PvP rounds are intensifying."},
        {600, "10-minute mark. Mid-game is crucial. Adjust your strategy!"},
        {900, "15-minute mark. Late game has begun. Prioritize high-cost champions!"}
    }
end

return TFTEvents
