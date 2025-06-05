local label = floof.class("Label", Element)

label.color = {1, 1, 1}
label.font = love.graphics.newFont("fonts/Roboto-Light.ttf", 32)

function label:init(parent, text, anchor, origin, color, font)
    self.parent = parent
    self.text = text or ""
    self.anchor = anchor
    self.origin = origin
    self.color = color
    self.font = font
end

function label:getSize()
    return vec(self.font:getWidth(self.text), self.font:getHeight())
end

function label:draw()
    local x, y = self:getPosition():unpack()
    local w, h = self:getSize():unpack()
    love.graphics.setFont(self.font)
    local color = self.color.text or self.color
    love.graphics.setColor(color)
    love.graphics.print(self.text, x - w/2, y - h/2)
end

return label