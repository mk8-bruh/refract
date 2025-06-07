local RayPreview = floof.class("RayPreview")

RayPreview.range = 10
RayPreview.dashSize = 0.25

function RayPreview:init(world, player, range)
    self.parent = world
    self.world = world
    self.player = player
    self.range = range
    self.ray = nil
end

function RayPreview:update(dt)
    self.ray = self.player and traceRay(self.player.cell, self.player.position, self.player.direction, self.range, self.player.light)
end

function RayPreview:draw()
    if self.ray then
        for d = 0, self.range, self.dashSize*2 do
            drawRay(self.ray, 0.01, d + self.dashSize, d + self.dashSize*2)
        end
    end
end

return RayPreview