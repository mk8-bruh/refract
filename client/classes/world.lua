local world = floof.class("World")

function world:init(seed)
    self.boltManager = BoltManager(self)
    self.particleManager = ParticleManager(self)
end

return world