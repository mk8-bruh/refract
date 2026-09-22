local RayPreview = Object:class("RayPreview")

RayPreview.range = 10
RayPreview.dashSize = 0.25

function RayPreview:__init(world, player, range)
    self.super.__init(self, {parent = world, world = world, player = player, range = range})
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
