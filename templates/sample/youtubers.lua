local youtube_channels = {
    electronics = {
        "GreatScott!",
        "ElectroBOOM",
        "EEVblog",
        "The Signal Path",
        "Afrotechmods",
        "Andreas Spiess",
        "Julian Ilett",
        "Big Clive",
        "Keysight Labs",
        "mikeselectricstuff"
    },
    retro_gaming = {
        "RetroRGB",
        "MetalJesusRocks",
        "Game Sack",
        "My Life in Gaming",
        "LGR (Lazy Game Reviews)",
        "Classic Gaming Quarterly",
        "8-Bit Guy",
        "Digital Foundry Retro",
        "Nostalgia Nerd",
        "Retro Recipes"
    },
    documentaries = {
        "Vox",
        "BBC Earth",
        "The Great War",
        "Veritasium",
        "Real Stories",
        "Wendover Productions",
        "CrashCourse",
        "Mustard",
        "PBS Eons",
        "Timeline - World History Documentaries",
        "Al Jazeera English (for Middle Eastern history and culture)",
        "NDTV (for Indian history and society)",
        "NHK World-Japan (for Japanese history and culture)",
        "RT Documentary (for Russian perspectives on history)",
        "CGTN Documentary (for Chinese history and culture)",
        "DW Documentary (for German history and global culture)",
        "France 24 (for French history and culture)",
        "SBS Dateline (for Australian history and perspectives)",
        "Storyteller Media (focused on African history from within)"
    },
    esports_culture_and_statistics = {
        "Esports Talk",
        "Score Esports",
        "ProGuides",
        "GosuGamers",
        "Overwatch League",
        "League of Legends Esports",
        "N0thing",
        "ThorIN",
        "Analyst Desk",
        "The Score's Esports Documentary Series"
    },
    computer_science_and_math = {
        "3Blue1Brown",
        "Computerphile",
        "Ben Eater",
        "The Coding Train",
        "MIT OpenCourseWare",
        "Tech With Tim",
        "Numberphile",
        "Gynvael Coldwind",
        "freeCodeCamp.org",
        "Clever Programmer"
    },
    engineering_and_makers = {
        "Mark Rober",
        "Simone Giertz",
        "Stuff Made Here",
        "DIY Perks",
        "Adam Savage’s Tested",
        "Applied Science",
        "Practical Engineering",
        "NileRed (for chemistry-related engineering)"
    },
    mathematics_focus = {
        "Mathologer",
        "Stand-up Maths",
        "Blackpenredpen",
        "Tibees",
        "Eddie Woo",
        "Dr. Trefor Bazett",
        "Mathsaurus",
        "Zach Star"
    },
    science_and_physics = {
        "PBS Space Time",
        "Kurzgesagt – In a Nutshell",
        "SciShow",
        "MinutePhysics",
        "SmarterEveryDay",
        "AsapSCIENCE",
        "Physics Girl",
        "Anton Petrov"
    },
    programming_and_software_development = {
        "Traversy Media",
        "The Net Ninja",
        "Code Bullet",
        "CodeWithHarry",
        "Fireship",
        "Dev Ed",
        "The Cherno",
        "Sentdex"
    },
    cultural_and_historical_documentaries = {
        "Al Jazeera English",
        "NHK World-Japan",
        "CGTN Documentary",
        "DW Documentary",
        "RT Documentary",
        "France 24",
        "Storyteller Media",
        "SBS Dateline",
        "History Matters (for concise histories of many nations)",
        "Kings and Generals (for in-depth, animated historical accounts)"
    },
    gaming_theories_and_analyses = {
        "The Game Theorists",
        "Zeltik",
        "Commonwealth Realm",
        "NintendoBlackCrisis",
        "Austin John Plays"
    },
    educational_and_informative = {
        "CoolVision",
        "RealLifeLore",
        "Wendover Productions",
        "Half as Interesting",
        "Geography Now"
    },
    retro_gaming_mechanics = {
        "Retro Game Mechanics Explained",
        "Summoning Salt",
        "Shesez (Boundary Break)",
        "Ahoy",
        "Gaming Historian"
    },
    electronic_music = {
        "Two Friends",
        "The Chainsmokers",
        "Louis The Child",
        "Gryffin",
        "Lost Kings"
    },
    advanced_factorio_gameplay = {
        "Nilaus",
        "Xterminator",
        "KatherineOfSky",
        "JD-Plays",
        "DoshDoshington"
    },
    advanced_minecraft_gameplay = {
        "ilmango",
        "Mumbo Jumbo",
        "EthosLab",
        "xisumavoid",
        "Cubfan135"
    },
    coding_in_games = {
        "Code Bullet",
        "SethBling",
        "Phoenix SC",
        "Tynker",
        "Program with Minecraft"
    },
    nintendo_story_playthroughs = {
        "ZeldaMaster",
        "AbdallahSmash026",
        "Domtendo",
        "ZackScottGames",
        "NintendoCentral"
    },
    other_story_playthroughs = {
        "TheRadBrad",
        "ChristopherOdd",
        "jacksepticeye",
        "MKIceAndFire",
        "Shirrako"
    },
    anime_reviews_and_analysis = {
        "Glass Reflection",
        "The Anime Man",
        "Super Eyepatch Wolf",
        "Mother's Basement",
        "Gigguk"
    },
    anime_music_videos_and_amvs = {
        "Kito Senpai",
        "AnimeHype",
        "xFrozenObsession",
        "SailorMoonAMVs",
        "AnimeUnity"
    },
    anime_news_and_discussions = {
        "Anime Balls Deep",
        "ForneverWorld",
        "Chibi Reviews",
        "Double4anime",
        "Lost Pause"
    },
    anime_top_tens_and_recommendations = {
        "WatchMojo.com",
        "AnimeTop10",
        "ViniiTube",
        "Otaku Sensei",
        "TopAnimeWeekly"
    },
    anime_reactions_and_live_streams = {
        "Akidearest",
        "Nux Taku",
        "CDawgVA",
        "TheAnimeMan",
        "Teeaboo"
    }
}

local function generateYoutubeSearchLinks(youtube_channels)
    local base_url = "https://www.youtube.com/results?search_query="
    local output = ""

    for category, channels in pairs(youtube_channels) do
        output = output .. "\n=== " .. category:upper() .. " ===\n"
        for _, channel in ipairs(channels) do
            local search_link = base_url .. channel:gsub(" ", "+")
            output = output .. "- " .. channel .. ": " .. search_link .. "\n"
        end
    end

    return output
end


-- Generate and print YouTube search links
local search_links = generateYoutubeSearchLinks(youtube_channels)
print(search_links)
