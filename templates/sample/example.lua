-- example.lua

-- 1. Write to a file
local file = io.open("example.txt", "w") -- Open file in write mode
if file then
    file:write("Hello, Lua!\nThis is a test file.\n")
    file:close()
    print("Data written to example.txt.")
else
    print("Failed to open file for writing.")
end

-- 2. Read from the file
local file = io.open("example.txt", "r") -- Open file in read mode
if file then
    print("Contents of example.txt:")
    for line in file:lines() do
        print(line)
    end
    file:close()
else
    print("Failed to open file for reading.")
end

-- 3. Perform a network request
local http = require("socket.http") -- LuaSocket HTTP module
local url = "http://httpbin.org/get"
local response, status_code = http.request(url)

if status_code == 200 then
    print("Network request successful!")
    print("Response:")
    print(response)
else
    print("Failed to fetch data from the URL. Status code:", status_code)
end

