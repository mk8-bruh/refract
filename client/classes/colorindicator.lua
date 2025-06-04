local colorIndicator = floof.class("ColorIndicator", Element)

function colorIndicator:init(parent, player, anchor, origin, size)
    self.parent = parent
    self.player = player
    self.anchor = anchor
    self.origin = origin
    self.size   = size
end

function colorIndicator:draw()
    if not self.player then return end
    local x, y = self:getPosition():unpack()
    local w, h = self:getSize():unpack()
    local s = math.min(w, h)
    local p1, p2, p3 = vec.polar(-math.pi/2, s/3), vec.polar(math.pi/6, s/3), vec.polar(5/6*math.pi, s/3)
    if self.player.lightToggles.red then
        love.graphics.setColor(self.player.lightMap.r.color)
        love.graphics.circle("fill", p1.x, p1.y, s/6)
    end
    if self.player.lightToggles.green then
        love.graphics.setColor(self.player.lightMap.g.color)
        love.graphics.circle("fill", p2.x, p2.y, s/6)
    end
    if self.player.lightToggles.blue then
        love.graphics.setColor(self.player.lightMap.b.color)
        love.graphics.circle("fill", p3.x, p3.y, s/6)
    end
    if self.player.currentLight then
        love.graphics.setColor(self.player.currentLight.color)
        love.graphics.circle("fill", x, y, s/3)
    else
        love.graphics.setColor(0, 0, 0)
        love.graphics.setLineWidth(3)
        love.graphics.circle("fill", x, y, s/3)
    end
end

return colorIndicator