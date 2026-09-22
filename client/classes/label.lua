local Label = Element:class("Label")

Label.textAlign = "center"
Label.color = {1, 1, 1}
Label.font = love.graphics.newFont("fonts/Roboto-Light.ttf", 32)

function Label:__init(parent, text, params)
    self.super.__init(self, mergeData({parent = parent, text = text}, params or {}))
end

function Label:__get_text()
    return rawget(self, "textString") or ""
end

function Label:__set_text(value)
    rawset(self, "textString", value)
    self:updateSize()
end

function Label:initialized()
    self:updateSize()
end

function Label:updateSize()
    autoSize(self, self.font:getWidth(self.text), self.font:getHeight())
end

function Label:draw()
    local x, y, w, h = self.x, self.y, self.w, self.h
    local tw, th = self.font:getWidth(self.text), self.font:getHeight()
    local s = math.min(w/tw, h/th, 1)
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.color)
    love.graphics.print(self.text,
        self.textAlign == "left" and x - w/2 or self.textAlign == "center" and x - s*tw/2 or self.textAlign == "right" and x + w/2 - s*tw,
        y - s*th/2,
    0, s)
end

return Label
