-- main.lua
local Timer = require("timer")
local util = require("util")

-- Choose the game
local game_name = arg[1] or "dota"

-- Supported games and their modules
local games = {
    dota = "games.dota",
    league = "games.league",
    smite = "games.smite",
    hots = "games.hots",
    pokemon_unite = "games.pokemon_unite",
    csgo = "games.csgo",
    valorant = "games.valorant",
    starcraft = "games.starcraft",
    fortnite = "games.fortnite",
    apex = "games.apex",
    pubg = "games.pubg",
    rocket_league = "games.rocket_league",
    r6 = "games.r6",
    fifa = "games.fifa",
    dead_by_daylight = "games.dead_by_daylight",
    tft = "games.tft",
    among_us = "games.among_us"
}

local game_module = games[game_name]
if not game_module then
    print("Unsupported game:", game_name)
    local game_list = util.keys(games)
    print("Supported games are: " .. table.concat(game_list, ", "))
    os.exit(1)
end

-- Load game-specific events and start the timer
local events = require(game_module).get_events()
Timer.start(events)

