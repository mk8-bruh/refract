local game = {check = true, tostring = "[game scene]"}

function game:init()
    self.ui = floof.new{parent = self, z = 1}
    self.fpsCounter = Title(self.ui, "FPS", nil, "top right", {1, 1, 1}, love.graphics.newFont(20))
    function self.fpsCounter:update(dt)
        self.text = ("%d FPS"):format(love.timer.getFPS())
    end
    self.colorIndicator = ColorIndicator(self.ui, nil, nil, "bottom right")
    self:resize(love.graphics.getDimensions())
end

function game:enter(prev, seed)
    self.world = World(self, 24, seed)
    self.player = Player(self.world, vec.polar(love.math.random() * 2 * math.pi, love.math.random(0, 12)))

    self.colorIndicator.player = self.player

    love.mouse.setRelativeMode(true)

    self.activeChild = self.player
    self.world.tracking = self.player
    self.world.rayPreview.player = self.player
end

function game:leave(next)
    self.world.parent = nil
    love.mouse.setRelativeMode(false)
end

function game:resize(w, h)
    self.fpsCounter.anchor = vec(w, 0)
    self.colorIndicator.size = vec.one * math.min(w, h) * 0.2
    self.colorIndicator.anchor = vec(w, h)
end

function game:keypressed(key)
    if key == "escape" then
        switchScene("Menu")
    end
end

return floof.new(game)