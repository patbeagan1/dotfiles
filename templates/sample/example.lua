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

-- -- 3. Perform a network request
-- local http = require("socket.http") -- LuaSocket HTTP module
-- local url = "http://httpbin.org/get"
-- local response, status_code = http.request(url)

-- if status_code == 200 then
--     print("Network request successful!")
--     print("Response:")
--     print(response)
-- else
--     print("Failed to fetch data from the URL. Status code:", status_code)
-- end

local Person = {
    name = "Patrick",

    greet = function(self, message)
        print(string.format("%s %s", message, self.name))
    end
}

function Person:enEspanol()
    self:greet("Hola")
end

Person:greet("Hello")

Person:enEspanol()

local a = os.execute("ls -1")
print(a)
print()

local kontext = require "kontext"

local shell = kontext.shell
local with = kontext.with

with(shell('ls -l'), function(it)
    print(it)
end)

kontext:of({3}):let(function(it)
    return it[1]
end):let(function(it)
    local v = it
    print(v)
    return v
end):let(function(it)
    print(it)
    return it
end):let(function(it)
    print(it)
    return it
end)

kontext:of({
    greet = function()
        print("hello")
    end
}):run(function()
    greet()
end)

kontext:of({
    a = 10
}):apply(function()
    b = 20
end):let(function(it)
    for k, v in pairs(it) do
        print(k)
    end

    print(it.a, it.b, it.c)
end)

kontext:of(shell("ls -ralt")):let(function(it)
    print(it)
end)

-- shell('ls -l'):let(function(it)
--     print(it)
-- end)
-- print(result)

for i = 1, 10, 1 do
    print()
end

