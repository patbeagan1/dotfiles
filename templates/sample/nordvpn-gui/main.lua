-- local UI = require("UI")

-- -- List of NordVPN Commands
-- local nordvpn_commands = {
--     {name = "account", input = false},
--     {name = "connect", input = true, description = "Enter server name (e.g., us123)"},
--     {name = "status", input = false},
--     {name = "disconnect", input = false},
--     {name = "rate", input = true, description = "Enter rating (1-5)"},
--     {name = "countries", input = false},
--     {name = "cities", input = false},
--     {name = "groups", input = false},
--     {name = "settings", input = false},
--     {name = "version", input = false},

--     -- Meshnet Commands
--     {name = "set meshnet on", input = false},
--     {name = "set meshnet off", input = false},
--     {name = "meshnet peer list", input = false},
--     {name = "meshnet peer add", input = true, description = "Enter peer IP to add"},
--     {name = "meshnet peer remove", input = true, description = "Enter peer IP to remove"},

--     -- Fileshare Commands
--     {name = "fileshare send", input = true, description = "Enter file path and peer IP (e.g., /path/to/file 192.168.1.2)"},
--     {name = "fileshare list", input = false},
--     {name = "fileshare delete", input = true, description = "Enter file ID to delete"},
--     {name = "fileshare accept", input = true, description = "Accept transfer (e.g., transfer_id [file_id])"},
--     {name = "fileshare cancel", input = true, description = "Cancel transfer (e.g., transfer_id [file_id])"},
--     {name = "fileshare clear", input = true, description = "Clear transfers older than specified time (e.g., 1d)"},

-- }

-- -- State
-- local output_text = "Welcome to the NordVPN Linux client app!"
-- local input_text = ""
-- local selected_command = nil
-- local window_width, window_height = 800, 600
-- local scroll_offset = 0

-- -- Execute NordVPN Command
-- local function execute_command(command, input)
--     local full_command = "nordvpn " .. command
--     if input and input ~= "" then
--         full_command = full_command .. " " .. input
--     end
    
--     local handle = io.popen(full_command .. " 2>&1") -- Capture command output
--     if handle then
--         local result = handle:read("*a")
--         handle:close()
--         return result
--     else
--         return "Error executing command: " .. full_command
--     end
-- end

-- function love.load()
--     love.window.setTitle("NordVPN Client GUI")
--     love.window.setMode(window_width, window_height, {resizable = true})
--     -- font = love.graphics.newFont("monospace", 14)
--     -- love.graphics.setFont(font)
-- end

-- function love.draw()
--     love.graphics.clear(1, 1, 1) -- White background
--     love.graphics.setColor(0, 0, 0) -- Black text
    
--     -- Title
--     love.graphics.print("NordVPN Client GUI", 10, 10 - scroll_offset)
    
--     -- Command Buttons
--     local btn_x, btn_y, btn_width, btn_height = 10, 50, 180, 30
--     for i, cmd in ipairs(nordvpn_commands) do
--         local y = btn_y + (btn_height + 5) * (i - 1) - scroll_offset
--         if y > 50 and y < window_height then
--             UI.button(btn_x, y, btn_width, btn_height, cmd.name, function()
--                 selected_command = cmd
--                 input_text = ""
--                 output_text = "Command: " .. cmd.name .. (cmd.input and "\n" .. cmd.description or "")
--             end)
--         end
--     end
    
--     -- Input Field
--     if selected_command and selected_command.input then
--         love.graphics.print("Input:", 220, 50)
--         UI.inputField(280, 50, 300, 30, input_text, "Type input here...")
--     end
    
--     -- Output Box
--     UI.outputBox(220, 100 - scroll_offset, 550, 450, output_text)
-- end

-- function love.textinput(t)
--     if selected_command and selected_command.input then
--         input_text = input_text .. t
--     end
-- end

-- function love.keypressed(key)
--     if key == "backspace" then
--         input_text = input_text:sub(1, -2)
--     elseif key == "return" and selected_command then
--         output_text = execute_command(selected_command.name, input_text)
--         selected_command = nil
--     end
-- end

-- function love.wheelmoved(_, y)
--     scroll_offset = scroll_offset - y * 20
--     if scroll_offset < 0 then scroll_offset = 0 end
-- end

-- function love.resize(w, h)
--     window_width, window_height = w, h
-- end

local CatUI = require("catui")

-- State
local selected_command = nil
local input_text = ""
local output_text = "Welcome to the NordVPN Linux client app!"

-- NordVPN Commands
local nordvpn_commands = {
    {name = "account", input = false},
    {name = "connect", input = true, description = "Enter server name (e.g., us123)"},
    {name = "status", input = false},
    {name = "disconnect", input = false},
    {name = "meshnet enable", input = false},
    {name = "fileshare send", input = true, description = "Send file to peer (e.g., /path/to/file 192.168.1.2)"}
}

function love.load()
    -- Initialize CatUI
    CatUI.init()

    -- Create UI elements
    local root = CatUI.Root()
    
    -- Left Column: Command Buttons
    local leftColumn = root:addColumn({width = "30%", spacing = 10, padding = 10})
    for _, cmd in ipairs(nordvpn_commands) do
        leftColumn:addButton({
            text = cmd.name,
            onClick = function()
                selected_command = cmd
                input_text = ""
                output_text = "Command: " .. cmd.name .. (cmd.input and ("\n" .. cmd.description) or "")
            end
        })
    end

    -- Right Column: Input Field and Output Box
    local rightColumn = root:addColumn({width = "70%", spacing = 10, padding = 10})

    -- Input Section
    rightColumn:addText({text = "Input:"})
    rightColumn:addInputField({
        placeholder = "Type input here...",
        bind = function(getText, setText)
            input_text = getText()
            CatUI.onKeyPress("return", function()
                if selected_command then
                    -- Execute Command
                    local command = "nordvpn " .. selected_command.name .. (input_text ~= "" and (" " .. input_text) or "")
                    local handle = io.popen(command .. " 2>&1")
                    output_text = handle and handle:read("*a") or "Error executing command."
                    if handle then handle:close() end
                    selected_command = nil
                    setText("")
                end
            end)
        end
    })

    -- Output Section
    rightColumn:addText({text = "Command Output:"})
    rightColumn:addBox({
        content = function()
            love.graphics.printf(output_text, 10, 10, love.graphics.getWidth() - 20)
        end,
        height = "auto"
    })
end

function love.update(dt)
    CatUI.update(dt)
end

function love.draw()
    CatUI.draw()
end

function love.mousepressed(x, y, button)
    CatUI.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    CatUI.mousereleased(x, y, button)
end

function love.textinput(text)
    CatUI.textinput(text)
end

function love.keypressed(key)
    CatUI.keypressed(key)
end

function love.keyreleased(key)
    CatUI.keyreleased(key)
end
