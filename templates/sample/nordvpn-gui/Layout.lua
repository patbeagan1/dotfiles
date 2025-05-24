local Layout = {}

-- A Box container for flexible UI content
function Layout.Box(config, draw_content)
    local x = config.x or 0
    local y = config.y or 0
    local width = config.width or love.graphics.getWidth()
    local height = config.height or love.graphics.getHeight()
    local padding = config.padding or 0
    local margin = config.margin or 0

    -- Calculate inner box position with padding and margin
    local inner_x = x + margin + padding
    local inner_y = y + margin + padding
    local inner_width = width - 2 * (padding + margin)
    local inner_height = height - 2 * (padding + margin)

    -- Draw the container (optional visual outline)
    if config.border then
        love.graphics.rectangle("line", x + margin, y + margin, width - 2 * margin, height - 2 * margin)
    end

    -- Draw the content inside the box
    love.graphics.push()
    love.graphics.translate(inner_x, inner_y)
    draw_content(inner_width, inner_height)
    love.graphics.pop()
end

-- Column Layout: Stacks elements vertically
function Layout.Column(config, children)
    local x = config.x or 0
    local y = config.y or 0
    local spacing = config.spacing or 5
    local current_y = y

    for _, child in ipairs(children) do
        child(current_y)
        current_y = current_y + spacing
    end
end

-- Row Layout: Stacks elements horizontally
function Layout.Row(config, children)
    local x = config.x or 0
    local y = config.y or 0
    local spacing = config.spacing or 5
    local current_x = x

    for _, child in ipairs(children) do
        child(current_x)
        current_x = current_x + spacing
    end
end

return Layout
