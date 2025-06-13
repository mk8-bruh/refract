local Label = floof.class("Label", Element)

Label.align = "center"
Label.color = {1, 1, 1}
Label.font = love.graphics.newFont("fonts/Roboto-Light.ttf", 32)

function Label:init(parent, text, params)
    self.parent = parent
    self.text = text or ""
    if params then copyData(params, self) end
end

function Label:getContentWidth()
    return self.font:getWidth(self.text)
end

function Label:getContentHeight()
    return self.font:getHeight()
end

function Label:draw()
    local x, y = self:getPosition():unpack()
    local w, h = self:getSize():unpack()
    local tw, th = self.font:getWidth(self.text), self.font:getHeight()
    local s = math.min(w/tw, h/th, 1)
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.color)
    love.graphics.print(self.text,
        self.align == "left" and x - w/2 or self.align == "center" and x - s*tw/2 or self.align == "right" and x + w/2 - s*tw,
        y - s*th/2,
    0, s)
end

return Label