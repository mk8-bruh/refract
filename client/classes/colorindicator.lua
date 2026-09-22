local ColorIndicator = Element:class("ColorIndicator")

ColorIndicator.lineWidth = 3
ColorIndicator.labelDirections = {
    r = 5/6 * math.pi,
    g = -math.pi/2,
    b = math.pi/6
}

function ColorIndicator:__init(parent, params)
    self.super.__init(self, mergeData({parent = parent}, params or {}))
end

function ColorIndicator:initialized()
    self.labels = {
        r = Label(self, nil, {inLayout = false}),
        g = Label(self, nil, {inLayout = false}),
        b = Label(self, nil, {inLayout = false})
    }
end

function ColorIndicator:labelPosition(key)
    return vec(self.x, self.y) + vec.polar(self.labelDirections[key], math.min(self.w, self.h)/3)
end

function ColorIndicator:update(dt)
    for key, label in pairs(self.labels) do
        label.x, label.y = self:labelPosition(key):unpack()
    end
    if self.player then
        self.labels.r.text = self.player.keybinds.red
        self.labels.g.text = self.player.keybinds.green
        self.labels.b.text = self.player.keybinds.blue
    end
end

function ColorIndicator:draw()
    if not self.player then return end
    local x, y = self.x, self.y
    local s = math.min(self.w, self.h)
    local toggles = {r = "red", g = "green", b = "blue"}
    -- mask
    love.graphics.clear(false, true, false)
    love.graphics.setLineWidth(self.lineWidth)
    -- toggles
    for _, key in ipairs{"r", "g", "b"} do
        local on = self.player.lightToggles[toggles[key]]
        local p = self:labelPosition(key)
        love.graphics.setColor(self.player.lightMap[key].color)
        love.graphics.circle(on and "fill" or "line", p.x, p.y, on and s/6 or s/6 - self.lineWidth/2)
        love.graphics.setStencilMode("draw", 1)
        love.graphics.circle("fill", p.x, p.y, s/6 * 1.1)
        love.graphics.setStencilMode()
    end
    -- final color
    love.graphics.setStencilMode("test", 0)
    if self.player.light then
        love.graphics.setColor(self.player.light.color)
        love.graphics.circle("fill", x, y, s/4)
    else
        love.graphics.setColor(self.player.lightMap.rgb.color)
        love.graphics.circle("line", x, y, s/4)
    end
    love.graphics.setStencilMode()
end

return ColorIndicator
