local button = floof.class("Button", Element)

button.color = {
    outline = {0, 0, 0},
    fill = {1, 1, 1},
    text = {0, 0, 0},
    hovered = {
        fill = {0.7, 0.7, 0.7}
    },
    pressed = {
        fill = {0, 0, 0},
        text = {1, 1, 1}
    }
}
button.font = love.graphics.newFont("fonts/Roboto-Light.ttf", 40) -- Changed font file to "Roboto-Black.ttf" in fonts directory
button.outlineWidth = 3
button.padding = vec(10, 10)
button.cornerRadius = 10

function button:init(parent, text, action, anchor, origin, color, font)
    self.parent = parent
    self.text = text
    self.action = action
    self.anchor = anchor
    self.origin = origin
    self.color = color
    self.font = font
end

function button:draw()
    local x, y = self:getPosition():unpack()
    local w, h = self:getSize():unpack()
    local tw, th = self.font:getWidth(self.text), self.font:getHeight()

    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.18)
    love.graphics.rectangle("fill", x - w/2 + 2, y - h/2 + 4, w, h, self.cornerRadius + 2)

    -- Button fill color
    local fill
    if self.isPressed then
        fill = {0.6, 0.6, 0.7}
    elseif self.isHovered then
        fill = {1, 1, 1}
    else
        fill = {0.92, 0.94, 1}
    end
    love.graphics.setColor(fill)
    love.graphics.rectangle("fill", x - w/2, y - h/2, w, h, self.cornerRadius)

    -- Outline
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.setLineWidth(self.outlineWidth)
    love.graphics.rectangle("line", x - w/2, y - h/2, w, h, self.cornerRadius)

    -- Text shadow
    love.graphics.setFont(self.font)
    love.graphics.setColor(0, 0, 0, 0.25)
    love.graphics.print(self.text, x - tw/2 + 2, y - th/2 + 2)

    -- Text
    local textColor = (self.isPressed and {1,1,1}) or (self.isHovered and {0.2,0.2,0.3}) or {0.1,0.1,0.2}
    love.graphics.setColor(textColor)
    love.graphics.print(self.text, x - tw/2, y - th/2)
end

function button:pressed(x, y, id)
    if type(id) == "number" and id > 1 then
        return false
    end
end

function button:released(x, y, id)
    if self.action then
        self:action()
    end
end

return button