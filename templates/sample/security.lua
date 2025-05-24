local lfs = require("lfs")
local os = require("os")

-- Define the base directory for storing account data
local home_dir = os.getenv("HOME")
local base_dir = home_dir .. "/.password_manager"

-- Utility to execute shell commands and capture output
local function execute_command(command)
    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()
    return result:match("^%s*(.-)%s*$") -- Trim whitespace
end

-- Ensure base directory exists
local function ensure_directory()
    if not lfs.attributes(base_dir, "mode") then
        os.execute("mkdir -p " .. base_dir)
        print("Created directory: " .. base_dir)
    end
end

-- Read a hidden password from the user
local function prompt_hidden(prompt)
    io.write(prompt)
    io.flush()
    os.execute("stty -echo") -- Disable echo
    local input = io.read("*l")
    os.execute("stty echo") -- Re-enable echo
    io.write("\n") -- Add newline for clarity after hidden input
    return input
end

-- Prompt user to confirm password by typing it twice
local function prompt_password()
    while true do
        local password1 = prompt_hidden("Enter password: ")
        local password2 = prompt_hidden("Re-enter password to confirm: ")
        if password1 == password2 then
            return password1
        else
            print("Passwords do not match. Please try again.")
        end
    end
end

-- Encrypt account data with GPG
local function encrypt_data(account_username, data, password)
    ensure_directory()
    local file_path = base_dir .. "/" .. account_username .. ".gpg"

    -- Write plaintext to a temporary file
    local tmp_file = base_dir .. "/temp.txt"
    local file = io.open(tmp_file, "w")
    if file then
        file:write(data)
        file:close()
    end

    -- Encrypt with GPG using master password
    local command = string.format("gpg --batch --yes --passphrase '%s' -c -o %s %s", password, file_path, tmp_file)
    os.execute(command)
    os.remove(tmp_file)

    print("Account '" .. account_username .. "' stored successfully!")
end

-- Decrypt account data with GPG
local function decrypt_data(account_username, password)
    local file_path = base_dir .. "/" .. account_username .. ".gpg"
    if not lfs.attributes(file_path, "mode") then
        print("Account '" .. account_username .. "' does not exist.")
        return nil
    end

    local command = string.format("gpg --batch --yes --passphrase '%s' --decrypt %s", password, file_path)
    return execute_command(command)
end

-- Copy data to the clipboard
local function copy_to_clipboard(data)
    if os.execute("which pbcopy > /dev/null") == 0 then
        -- macOS
        local pipe = io.popen("pbcopy", "w")
        if pipe then
            pipe:write(data)
            pipe:close()
        end
        print("Password copied to clipboard!")
    elseif os.execute("which xclip > /dev/null") == 0 then
        -- Linux
        local pipe = io.popen("xclip -selection clipboard", "w")
        if pipe then
            pipe:write(data)
            pipe:close()
        end
        print("Password copied to clipboard!")
    elseif os.execute("which clip > /dev/null") == 0 then
        -- Windows
        local pipe = io.popen("clip", "w")
        if pipe then
            pipe:write(data)
            pipe:close()
        end
        print("Password copied to clipboard!")
    else
        print("Clipboard tool not found. Please install 'pbcopy', 'xclip', or 'clip'.")
    end
end

-- List all accounts
local function list_accounts()
    ensure_directory()
    for file in lfs.dir(base_dir) do
        if file:match("%.gpg$") then
            print(file:gsub("%.gpg$", "")) -- Remove .gpg extension
        end
    end
end

-- Add a new account
local function add_account(service, username)
    local account_username = service .. "_" .. username
    local password = prompt_password()
    local data = string.format("username: %s\npassword: %s", username, password)
    encrypt_data(account_username, data, os.getenv("MASTER_PASSWORD"))
end

-- Get an account's details and copy password to clipboard
local function get_account(service, username)
    local account_username = service .. "_" .. username
    local data = decrypt_data(account_username, os.getenv("MASTER_PASSWORD"))
    if data then
        print("Account: " .. account_username)
        local password = data:match("password: (.+)")
        if password then
            copy_to_clipboard(password)
        else
            print("Password not found in account data.")
        end
    end
end

-- Migrate to a new master password
local function migrate_master_password(old_password, new_password)
    ensure_directory()

    print("Starting master password migration...")

    for file in lfs.dir(base_dir) do
        if file:match("%.gpg$") then
            print("Processing: " .. file)
            local filename = file.gsub(".gpg", "") 

            -- Decrypt with the old password
            local decrypted_data = decrypt_data(filename, old_password)
            print(string.format("%s, %s", filename, old_password))
            if not decrypted_data then
                print("Skipping file due to decryption failure: " .. filename)
                return false
            end

            -- Re-encrypt with the new password
            encrypt_data(decrypted_data, filename, new_password)
            print("Successfully migrated: " .. file)
        end
    end

    print("Master password migration completed successfully.")
    return true
end

-- Command-line interface
local function main(...)
    local args = {...}
    if #args < 1 then
        print("Usage:")
        print("  lua password_manager.lua add <service> <username>")
        print("  lua password_manager.lua get <service> <username>")
        print("  lua password_manager.lua list")
        print("  lua password_manager.lua migrate")
        os.exit(1)
    end

    -- Check if MASTER_PASSWORD is set
    if not os.getenv("MASTER_PASSWORD") then
        print("Error: MASTER_PASSWORD environment variable is not set.")
        os.exit(1)
    end

    local command = args[1]
    if command == "add" and #args == 3 then
        local service, username = args[2], args[3]
        add_account(service, username)
    elseif command == "get" and #args == 3 then
        local service, username = args[2], args[3]
        get_account(service, username)
    elseif command == "list" and #args == 1 then
        list_accounts()
    elseif command == "migrate" and #args == 1 then
        -- Prompt for old and new passwords
        if not os.getenv("MASTER_PASSWORD") then
            print("Error: MASTER_PASSWORD environment variable is not set.")
            os.exit(1)
        end

        local old_password = os.getenv("MASTER_PASSWORD")
        local new_password = prompt_hidden("Enter new master password: ")
        local confirm_password = prompt_hidden("Re-enter new master password to confirm: ")

        if new_password ~= confirm_password then
            print("Passwords do not match. Migration aborted.")
            os.exit(1)
        end

        migrate_master_password(old_password, new_password)
        print("Migration Complete!\nPlease remember to update the MASTER_PASSWORD environment variable")
    else
        print("Invalid arguments. Use 'add', 'get', or 'list'.")
    end
end

main(...)
