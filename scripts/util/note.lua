#!/usr/bin/env lua

-- luarocks --local install luasocket
-- luarocks --local install luafilesystem

-- Enhanced Note-Taking App in Lua
local lfs = require("lfs") -- Lua File System module for managing files

local notes_dir = "notes"

-- Ensure notes directory exists
local function ensure_notes_dir()
    if not lfs.attributes(notes_dir, "mode") then
        lfs.mkdir(notes_dir)
        print("Created notes directory: " .. notes_dir)
    end
end

-- Helper function: Get all note names
local function get_all_notes()
    local notes = {}
    for file in lfs.dir(notes_dir) do
        if file:match("%.md$") then
            local name_new = file:gsub("%.md$", "")
            print(name_new)
            table.insert(notes, name_new) -- Remove the ".md" extension
        end
    end
    return notes
end

-- Helper function: Fuzzy match for autocomplete
local function fuzzy_match(input, choices)
    local matches = {}
    for _, choice in ipairs(choices) do
        if choice:lower():find(input:lower(), 1, true) then
            table.insert(matches, choice)
        end
    end
    return matches
end

-- Autocomplete prompt
local function autocomplete_prompt(prompt, choices)
    io.write(prompt)
    local input = io.read()
    local matches = fuzzy_match(input, choices)
    if #matches == 1 then
        return matches[1]
    elseif #matches > 1 then
        print("Multiple matches found:")
        for i, match in ipairs(matches) do
            print(i .. ". " .. match)
        end
        io.write("Choose a number (or press Enter to cancel): ")
        local choice = tonumber(io.read())
        if choice and matches[choice] then
            return matches[choice]
        end
    else
        print("No matches found.")
    end
    return nil
end

-- List all notes
local function list_notes()
    local notes = get_all_notes()
    if #notes == 0 then
        print("No notes available.")
    else
        print("Available notes:")
        for _, note in ipairs(notes) do
            print("- " .. note)
        end
    end
end

-- Create a new note
local function create_note()
    io.write("Enter new note name: ")
    local note_name = io.read()
    local file_path = notes_dir .. "/" .. note_name .. ".md"
    if lfs.attributes(file_path, "mode") then
        print("Error: Note already exists.")
        return
    end
    print("Write your note content (end with an empty line):")
    local content = {}
    while true do
        local line = io.read()
        if line == "" then break end
        table.insert(content, line)
    end
    local file = io.open(file_path, "w")
    file:write(table.concat(content, "\n"))
    file:close()
    print("Note created: " .. file_path)
end

-- Read a note
local function read_note()
    local notes = get_all_notes()
    if #notes == 0 then
        print("No notes available to read.")
        return
    end
    local note_name = autocomplete_prompt("Enter note name (partial name allowed): ", notes)
    if not note_name then
        print("Read operation cancelled.")
        return
    end
    local file_path = notes_dir .. "/" .. note_name .. ".md"
    local file = io.open(file_path, "r")
    if not file then
        print("Error: Note not found.")
        return
    end
    print("\n--- Content of " .. note_name .. ".md ---")
    print(file:read("*a"))
    file:close()
end

-- Delete a note
local function delete_note()
    local notes = get_all_notes()
    if #notes == 0 then
        print("No notes available to delete.")
        return
    end
    local note_name = autocomplete_prompt("Enter note name to delete (partial name allowed): ", notes)
    if not note_name then
        print("Delete operation cancelled.")
        return
    end
    local file_path = notes_dir .. "/" .. note_name .. ".md"
    if not lfs.attributes(file_path, "mode") then
        print("Error: Note not found.")
        return
    end
    os.remove(file_path)
    print("Note deleted: " .. file_path)
end

-- Main menu
local function main_menu()
    ensure_notes_dir()
    while true do
        print("\n--- Enhanced Note-Taking App ---")
        print("1. List Notes")
        print("2. Create Note")
        print("3. Read Note")
        print("4. Delete Note")
        print("5. Exit")
        io.write("Choose an option: ")
        local choice = tonumber(io.read())
        if choice == 1 then
            list_notes()
        elseif choice == 2 then
            create_note()
        elseif choice == 3 then
            read_note()
        elseif choice == 4 then
            delete_note()
        elseif choice == 5 then
            print("Goodbye!")
            break
        else
            print("Invalid choice, please try again.")
        end
    end
end

-- Run the app
main_menu()

