-- games/pokemon_unite.lua
local PokemonUniteEvents = {}

function PokemonUniteEvents.get_events()
    return {
        {0, "Welcome to Aeos Island! Get ready for battle."},
        {10, "10 seconds to wild Pokemon spawn. Position yourself."},
        {20, "Wild Pokemon have spawned. Farm XP!"},
        {300, "5-minute mark. Drednaw is spawning soon. Secure shields and XP!"},
        {420, "7-minute mark. Rotom is spawning. Push the top lane!"},
        {480, "8-minute mark. Zapdos will spawn soon. Prepare for the final battle!"},
        {600, "10-minute mark. Zapdos is up. This is the game-deciding moment!"}
    }
end

return PokemonUniteEvents
