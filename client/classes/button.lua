local button = floof.class("Button")

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
button.font = love.graphics.newFont(30)
button.outlineWidth = 3
button.padding = vec(10, 10)
button.cornerRadius = 10

function button:init(parent, text, action, position, color, font)
    self.parent = parent
    self.text = text
    self.action = action
    self.position = position
    self.color = color
    self.font = font
end

function button:getSize()
    return vec(self.width or self.font:getWidth(self.text) + self.padding.x, self.height or self.font:getHeight() + self.padding.y)
end

function button:draw()
    local x, y = self.position:unpack()
    local w, h = self:getSize():unpack()
    local tw, th = self.font:getWidth(self.text), self.font:getHeight()
    love.graphics.setColor(
        (self.isPressed and self.color.pressed and self.color.pressed.fill) or
        (self.isHovered and self.color.hovered and self.color.hovered.fill) or
        self.color.fill
    )
    love.graphics.rectangle("fill", x - w/2, y - h/2, w, h, self.cornerRadius)
    love.graphics.setColor(
        (self.isPressed and self.color.pressed and self.color.pressed.outline) or
        (self.isHovered and self.color.hovered and self.color.hovered.outline) or
        self.color.outline
    )
    love.graphics.setLineWidth(self.outlineWidth)
    love.graphics.rectangle("line", x - w/2, y - h/2, w, h, self.cornerRadius)
    love.graphics.setColor(
        (self.isPressed and self.color.pressed and self.color.pressed.text) or
        (self.isHovered and self.color.hovered and self.color.hovered.text) or
        self.color.text
    )
    love.graphics.setFont(self.font)
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