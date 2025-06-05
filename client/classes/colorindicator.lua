local colorIndicator = floof.class("ColorIndicator", Element)

function colorIndicator:init(parent, player, anchor, origin, size)
    self.parent = parent
    self.player = player
    self.anchor = anchor
    self.origin = origin
    self.size   = size

    local labelFont = love.graphics.newFont(30)
    self.labels = {
        r = Title(self, nil, nil, nil, {1, 1, 1}, labelFont),
        g = Title(self, nil, nil, nil, {1, 1, 1}, labelFont),
        b = Title(self, nil, nil, nil, {1, 1, 1}, labelFont)
    }
end

function colorIndicator:update(dt)
    local x, y = self:getPosition():unpack()
    local w, h = self:getSize():unpack()
    local p = vec(x, y)
    local s = math.min(w, h)

    self.labels.r.anchor = p + vec.polar(5/6*math.pi, s/3)
    self.labels.g.anchor = p + vec.polar(-math.pi/2, s/3)
    self.labels.b.anchor = p + vec.polar(math.pi/6, s/3)
    if self.player then
        self.labels.r.text = self.player.keybinds.red
        self.labels.g.text = self.player.keybinds.green
        self.labels.b.text = self.player.keybinds.blue
    end
end

function colorIndicator:draw()
    if not self.player then return end
    local x, y = self:getPosition():unpack()
    local w, h = self:getSize():unpack()
    local s = math.min(w, h)
    -- mask
    love.graphics.stencil(function()
        love.graphics.rectangle("fill", x - w/2, y - h/2, w, h)
    end, "replace", 0)
    love.graphics.setLineWidth(3)
    -- toggles
    love.graphics.setColor(self.player.lightMap.r.color)
    love.graphics.circle(self.player.lightToggles.red and "fill" or "line", self.labels.r.anchor.x, self.labels.r.anchor.y, s/6)
    love.graphics.stencil(function()
        love.graphics.circle("fill", self.labels.r.anchor.x, self.labels.r.anchor.y, s/6 * 1.1)
    end, "replace", 1, true)
    love.graphics.setColor(self.player.lightMap.g.color)
    love.graphics.circle(self.player.lightToggles.green and "fill" or "line", self.labels.g.anchor.x, self.labels.g.anchor.y, s/6)
    love.graphics.stencil(function()
        love.graphics.circle("fill", self.labels.g.anchor.x, self.labels.g.anchor.y, s/6 * 1.1)
    end, "replace", 1, true)
    love.graphics.setColor(self.player.lightMap.b.color)
    love.graphics.circle(self.player.lightToggles.blue and "fill" or "line", self.labels.b.anchor.x, self.labels.b.anchor.y, s/6)
    love.graphics.stencil(function()
        love.graphics.circle("fill", self.labels.b.anchor.x, self.labels.b.anchor.y, s/6 * 1.1)
    end, "replace", 1, true)
    -- final color
    love.graphics.setStencilTest("equal", 0)
    if self.player.light then
        love.graphics.setColor(self.player.light.color)
        love.graphics.circle("fill", x, y, s/3)
    else
        love.graphics.setColor(self.player.lightMap.rgb.color)
        love.graphics.circle("line", x, y, s/3)
    end
    love.graphics.setStencilTest()
end

return colorIndicator