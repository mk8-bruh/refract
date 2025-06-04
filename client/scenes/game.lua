local game = {check = true, tostring = "[game scene]"}

function game:init()
    -- world
    self.world = floof.new{parent = self}
    self.world.particles = ParticleManager(self.world)
    self.world.particles.z = 1
    self.world.bolts = BoltManager(self.world)
    self.world.bolts.z = 3

    self.player = Player(self.world)
    self.player.z = 4

    -- UI
    self.ui = floof.new{parent = self, z = 1}
    self.fpsCounter = Title(self.ui, "FPS", nil, "top right")
    function self.fpsCounter:update(dt)
        self.text = ("%d FPS"):format(love.time.getFPS())
    end
    self.colorIndicator = ColorIndicator(self.ui, self.player)

    self:resize(love.graphics.getDimensions())
end

function game:resize(w, h)
    self.fpsCounter:setPosition(vec(w, 0))
    self.colorIndicator.size = vec.one * math.min(w, h) * 0.2
    self.colorIndicator:setPosition(vec(w, h))
end

function game:draw()
    
end

return floof.new(game)