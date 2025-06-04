local title = floof.class("Title", Element)

title.color = {0, 0, 0}
title.font = love.graphics.newFont(100)

function title:init(parent, text, anchor, origin, color, font)
    self.parent = parent
    self.text = text
    self.anchor = anchor
    self.origin = origin
    self.color = color
    self.font = font
end

function title:draw()
    local x, y = self:getPosition():unpack()
    local w, h = self:getSize():unpack()
    love.graphics.setColor(self.color)
    love.graphics.setFont(self.font)
    love.graphics.print(self.text, x - w/2, y - h/2)
end

return title