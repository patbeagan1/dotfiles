local UI = {}

-- Button Component
function UI.button(x, y, width, height, label, onClick)
    -- Draw button
    love.graphics.rectangle("line", x, y, width, height)
    love.graphics.print(label, x + 10, y + 5)
    
    -- Handle mouse click
    if love.mouse.isDown(1) then
        local mx, my = love.mouse.getPosition()
        if mx > x and mx < x + width and my > y and my < y + height then
            onClick()
        end
    end
end

-- Input Field Component
function UI.inputField(x, y, width, height, text, placeholder)
    love.graphics.rectangle("line", x, y, width, height)
    if text == "" then
        love.graphics.setColor(0.5, 0.5, 0.5) -- Gray for placeholder
        love.graphics.print(placeholder, x + 5, y + 5)
        love.graphics.setColor(0, 0, 0)
    else
        love.graphics.print(text, x + 5, y + 5)
    end
end

-- Output Box Component
function UI.outputBox(x, y, width, height, text)
    love.graphics.rectangle("line", x, y, width, height)
    love.graphics.printf(text, x + 5, y + 5, width - 10)
end

return UI
