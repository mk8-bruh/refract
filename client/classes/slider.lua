local Slider = Element:class("Slider")

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
Slider.min = 0
Slider.max = 1

function Slider:__init(parent, min, max, value, action, params)
    self.super.__init(self, mergeData({parent = parent, min = min, max = max, value = value, action = action}, params or {}))
end

function Slider:initialized()
    if self.value == nil then
        self.value = self.min
    end
end

function Slider:setValue(value)
    self.value = math.max(self.min, math.min(self.max, value))
end

function Slider:getKnobPosition()
    return self.l + self.h/2 + (self.w - self.h) * (self.value - self.min) / (self.max - self.min)
end

function Slider:draw()
    local y, h = self.y, self.h
    local xmin, xmax = self.l + h/2, self.r - h/2
    local sx = self:getKnobPosition()

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
    local sx = self:getKnobPosition()
    return math.sqrt((x - sx)^2 + (y - self.y)^2) <= self.h/2
end

function Slider:pressed(x, y, press, isTouch)
    if not isTouch and press > 1 then
        return false
    end
end

function Slider:dragged(x, y, dx, dy)
    local sx = math.max(0, math.min(self.w - self.h, x - (self.l + self.h/2)))
    self.value = self.min + sx / (self.w - self.h) * (self.max - self.min)
    return true
end

function Slider:released(x, y, press, isTouch)
    if self.action then
        self:action(self.value)
    end
end

return Slider
