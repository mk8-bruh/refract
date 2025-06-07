local Button = floof.class("Button", Element)

Button.color = {
    outline = {0.2, 0.2, 0.3},
    fill = {0.92, 0.94, 1},
    text = {0.1, 0.1, 0.2},
    hovered = {
        fill = {1, 1, 1},
        text = {0.2, 0.2, 0.3}
    },
    pressed = {
        fill = {0.6, 0.6, 0.7},
        text = {1, 1, 1}
    },
    shadow = {0, 0, 0, 0.2}
}
Button.font = love.graphics.newFont("fonts/Roboto-Light.ttf", 40)
Button.outlineWidth = 3
Button.padding = vec(10, 10)
Button.cornerRadius = 10

function Button:init(parent, text, action, params)
    self.parent = parent
    self.text = text
    self.action = action
    if params then copyData(params, self) end
end

function Button:getSize()
    return vec(self.width or (self.font:getWidth(self.text) + self.padding.x * 2), self.height or (self.font:getHeight() + self.padding.y * 2))
end

function Button:draw()
    local x, y = self:getPosition():unpack()
    local w, h = self:getSize():unpack()
    local tw, th = self.font:getWidth(self.text), self.font:getHeight()
    local ts = math.min((w - self.padding.x * 2) / tw, (h - self.padding.y * 2) / th, 1)

    -- Shadow
    love.graphics.setColor(self.color.shadow)
    love.graphics.rectangle("fill", x - w/2 + 2, y - h/2 + 4, w, h, self.cornerRadius + 2)

    -- Fill
    love.graphics.setColor(
        self.isPressed and self.color.pressed and self.color.pressed.fill or
        self.isHovered and self.color.hovered and self.color.hovered.fill or
        self.color.fill
    )
    love.graphics.rectangle("fill", x - w/2, y - h/2, w, h, self.cornerRadius)

    -- Outline
    love.graphics.setColor(
        self.isPressed and self.color.pressed and self.color.pressed.outline or
        self.isHovered and self.color.hovered and self.color.hovered.outline or
        self.color.outline
    )
    love.graphics.setLineWidth(self.outlineWidth)
    love.graphics.rectangle("line", x - w/2, y - h/2, w, h, self.cornerRadius)

    -- Text shadow
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.color.shadow)
    love.graphics.print(self.text, x - ts*tw/2 + 2, y - ts*th/2 + 2, 0, ts)

    -- Text
    love.graphics.setFont(self.font)
    love.graphics.setColor(
        self.isPressed and self.color.pressed and self.color.pressed.text or
        self.isHovered and self.color.hovered and self.color.hovered.text or
        self.color.text
    )
    love.graphics.print(self.text, x - ts*tw/2, y - ts*th/2, 0, ts)
end

function Button:pressed(x, y, id)
    if type(id) == "number" and id > 1 then
        return false
    end
end

function Button:released(x, y, id)
    if self.action then
        self:action()
    end
end

return Button