local particleManager = floof.class("ParticleManager")

particleManager.particleLifetime = 1
particleManager.particleEaseOut = 4
particleManager.particleStartOpacity = 1
particleManager.particleEndOpacity = 0
particleManager.particleStartRadius = 0.02
particleManager.particleEndRadius = 0.2

function particleManager:init(world)
    self.parent = world
    self.world = world
end

function particleManager:add(position, color)
    table.insert(self, {
        position = position,
        color = color,
        lifetime = 0
    })
end

function particleManager:update(dt)
    for i = #self, 1, -1 do
        local particle = self[i]
        particle.lifetime = particle.lifetime + dt
        if particle.lifetime > self.particleLifetime then
            table.remove(self, i)
        end
    end
end

function particleManager:draw()
    for _, particle in ipairs(self) do
        local t = 1 - (-(particle.lifetime/self.particleLifetime - 1)) ^ self.particleEaseOut
        love.graphics.setColor(particle.color[1], particle.color[2], particle.color[3], self.particleStartOpacity + (self.particleEndOpacity - self.particleStartOpacity) * t)
        love.graphics.circle("fill", particle.position.x, particle.position.y, self.particleStartRadius + (self.particleEndRadius - self.particleStartRadius) * t)
    end
end

return particleManager