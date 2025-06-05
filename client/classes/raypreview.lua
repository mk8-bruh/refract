local rayPreview = floof.class("RayPreview")

rayPreview.range = 10
rayPreview.dashSize = 0.25

function rayPreview:init(world, player, range)
    self.parent = world
    self.world = world
    self.player = player
    self.range = range
    self.ray = nil
end

function rayPreview:update(dt)
    self.ray = self.player and traceRay(self.player.cell, self.player.position, self.player.direction, self.range, self.player.light)
end

function rayPreview:draw()
    if self.ray then
        for d = 0, self.range, self.dashSize*2 do
            drawRay(self.ray, 0.01, d + self.dashSize, d + self.dashSize*2)
        end
    end
end

return rayPreview