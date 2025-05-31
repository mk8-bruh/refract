local title = floof.class("Title")

title.color = {0, 0, 0}
title.font = love.graphics.newFont(100)

function title:init(parent, text, position, color, font)
    self.parent = parent
    self.text = text
    self.position = position
    self.color = color
    self.font = font
end

function title:getSize()
    return vec(self.font:getWidth(self.text), self.font:getHeight())
end

function title:draw()
    local x, y = self.position:unpack()
    local w, h = self:getSize():unpack()
    love.graphics.setColor(self.color)
    love.graphics.setFont(self.font)
    love.graphics.print(self.text, x - w/2, y - h/2)
end

return title