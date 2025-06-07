local BoltManager = floof.class("BoltManager")

BoltManager.boltSpeed = 30
BoltManager.boltLength = 1
BoltManager.traceDistance = 15
BoltManager.maxBounces = 6

function BoltManager:init(world)
    self.parent = world
    self.world = world
end

function BoltManager:add(cell, position, direction, light, power)
    table.insert(self, {
        ray = tracePartial(self.traceDistance, cell, position, direction, light, power),
        range = self.traceDistance,
        distance = 0,
        bounces = 0
    })
end

function BoltManager:shoot(player)
    table.insert(self, {
        ray = tracePartial(self.traceDistance, player.cell, player.position, player.direction, player.light, player.power),
        range = self.traceDistance,
        distance = 0,
        bounces = 0,
        owner = player
    })
end

function BoltManager:update(dt)
    local inc = self.boltSpeed * dt
    for i = #self, 1, -1 do
        local bolt = self[i]
        bolt.distance = bolt.distance + inc
        if bolt.distance > bolt.ray.length and not bolt.impacted then
            if bolt.ray.hit then
                local c = (bolt.ray.reflect and bolt.ray.reflect[4] and bolt.ray.reflect[4].color) or (not bolt.ray.refract and bolt.ray.light and bolt.ray.light.color)
                if c then
                    self.world.particleManager:add(bolt.ray.hit.point, c)
                end
            end
            if bolt.ray.refract then
                table.insert(self, {
                    ray = tracePartial(bolt.range - bolt.ray.length, unpack(bolt.ray.refract)),
                    range = bolt.range - bolt.ray.length,
                    distance = bolt.distance - bolt.ray.length,
                    bounces = bolt.bounces,
                    owner = bolt.owner
                })
            end
            if bolt.ray.reflect and bolt.bounces < self.maxBounces then
                table.insert(self, {
                    ray = tracePartial(self.traceDistance, unpack(bolt.ray.reflect)),
                    range = self.traceDistance,
                    distance = bolt.distance - bolt.ray.length,
                    bounces = bolt.bounces + 1,
                    owner = bolt.owner
                })
            end
            bolt.impacted = true
        end
        if bolt.distance - self.boltLength > bolt.ray.length then
            table.remove(self, i)
        end
    end
end

function BoltManager:draw()
    for _, bolt in ipairs(self) do
        drawPartial(bolt.ray, 0.09, bolt.distance - self.boltLength, bolt.distance, 1)
        drawPartial(bolt.ray, 0.03, bolt.distance - self.boltLength, bolt.distance, 1, {1, 1, 1})
    end
end

return BoltManager