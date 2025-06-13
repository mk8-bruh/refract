local Slider = floof.class("Slider", Element)

Slider.color = {
    left = {0.2, 0.2, 0.3},
    right = {0.2, 0.2, 0.3},
    outline = {0.2, 0.2, 0.3},
    fill = {0.92, 0.94, 1},
    hovered = {
        fill = {1, 1, 1}
    },
    pressed = {
        fill = {0.6, 0.6, 0.7}
    },
    shadow = {0, 0, 0, 0.2}
}
Slider.lineWidth = {
    left = 8, right = 8
}
Slider.outlineWidth = 3
Slider.shadowOffset = vec(2, 4)

function Slider:init(parent, min, max, value, action, params)
    self.parent = parent
    self.min = min or 0
    self.max = max or 1
    self.action = action
    if params then copyData(params, self) end

    self.value = value or self.min
end

function Slider:setValue(value)
    self.value = math.max(self.min, math.min(self.max, value))
end

function Slider:draw()
    local x, y = self:getPosition():unpack()
    local w, h = self:getSize():unpack()
    local xmin, xmax = x - w/2 + h/2, x + w/2 - h/2
    local sx = xmin + (xmax - xmin) * (self.value - self.min) / (self.max - self.min)

    -- Shadow
    love.graphics.setColor(self.color.shadow)
    love.graphics.rectangle("fill", xmin + self.shadowOffset.x, y - self.lineWidth.left/2 + self.shadowOffset.y, sx - xmin, self.lineWidth.left, self.lineWidth.left/2)
    love.graphics.rectangle("fill", sx + self.shadowOffset.x, y - self.lineWidth.right/2 + self.shadowOffset.y, xmax - sx, self.lineWidth.right, self.lineWidth.right/2)
    love.graphics.circle("fill", sx + self.shadowOffset.x, y + self.shadowOffset.y, h/2)

    -- Line
    love.graphics.setColor(
        self.isPressed and self.color.pressed and self.color.pressed.left or
        self.isHovered and self.color.hovered and self.color.hovered.left or
        self.color.left
    )
    love.graphics.rectangle("fill", xmin, y - self.lineWidth.left/2, sx - xmin, self.lineWidth.left, self.lineWidth.left/2)
    love.graphics.setColor(
        self.isPressed and self.color.pressed and self.color.pressed.right or
        self.isHovered and self.color.hovered and self.color.hovered.right or
        self.color.right
    )
    love.graphics.rectangle("fill", sx, y - self.lineWidth.right/2, xmax - sx, self.lineWidth.right, self.lineWidth.right/2)

    -- Circle fill
    love.graphics.setColor(
        self.isPressed and self.color.pressed and self.color.pressed.fill or
        self.isHovered and self.color.hovered and self.color.hovered.fill or
        self.color.fill
    )
    love.graphics.circle("fill", sx, y, h/2)

    -- Outline
    love.graphics.setColor(
        self.isPressed and self.color.pressed and self.color.pressed.outline or
        self.isHovered and self.color.hovered and self.color.hovered.outline or
        self.color.outline
    )
    love.graphics.setLineWidth(self.outlineWidth)
    love.graphics.circle("line", sx, y, h/2)
end

function Slider:check(x, y)
    local px, py = self:getPosition():unpack()
    local w, h = self:getSize():unpack()
    local sx = px - w/2 + h/2 + (w - h) * (self.value - self.min) / (self.max - self.min)
    return math.sqrt((x - sx)^2 + (y - py)^2) <= h/2
end

function Slider:pressed(x, y, id)
    if type(id) == "number" and id > 1 then
        return false
    end
end

function Slider:moved(x, y, dx, dy)
    local px, py = self:getPosition():unpack()
    local w, h = self:getSize():unpack()
    local sx = math.max(0, math.min(w - h, x - (px - w/2 + h/2)))
    self.value = self.min + sx / (w - h) * (self.max - self.min)
    return true
end

function Slider:released(x, y, id)
    if self.action then
        self:action(self.value)
    end
end

return Slider