#!/usr/bin/env lua5.1

-- needs to be 5.1 because setfenv is reworked in 5.2

local function HtmlDSL(env, block)
    -- Setup environment with HTML tag functions
    local html_env = setmetatable({}, {
        __index = function(_, tag)
            return function(attributes, children)
                -- Generate HTML tag dynamically
                local attrString = ""
                if attributes then
                    for k, v in pairs(attributes) do
                        attrString = attrString .. string.format(' %s="%s"', k, v)
                    end
                end
                local openingTag = string.format("<%s%s>", tag, attrString)

                -- Handle children (strings or nested tags)
                local childContent = ""
                if type(children) == "table" then
                    for _, child in ipairs(children) do
                        childContent = childContent .. child
                    end
                elseif type(children) == "string" then
                    childContent = children
                end

                local closingTag = string.format("</%s>", tag)
                return openingTag .. childContent .. closingTag
            end
        end
    })

    -- Run the provided block within the context
    setfenv(block, html_env)
    return table.concat(block())
end

-- Example Usage
local html = HtmlDSL({}, function()
    return {
        html(nil, {
            head (nil, {
                title(nil, "My Lua DSL Page")
            }),
            body({ class = "main-body" }, {
                h1(nil, "Welcome to Lua DSL!"),
                p(nil, "This is a more concise example."),
                a({ href = "https://www.lua.org/" }, "Learn more about Lua"),
                ul(nil, {
                    li(nil, "Item 1"),
                    li(nil, "Item 2"),
                    li(nil, "Item 3")
                })
            })
        })
    }
end)

-- Output the HTML
print(html)
