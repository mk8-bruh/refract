local game = {check = true, tostring = "[game scene]"}

function game:init()
    self.ui = floof.new{parent = self, z = 1}
    self.fpsCounter = Label(self.ui, "FPS", {origin = "top right", font = love.graphics.newFont(12)})
    function self.fpsCounter:update(dt)
        self.text = ("%d FPS"):format(love.timer.getFPS())
    end
    self.colorIndicator = ColorIndicator(self.ui, {origin = "bottom right"})
end

function game:enter(prev, seed)
    self.world = World(self, 24, seed)
    self.player = Player(self.world, vec.polar(love.math.random() * 2 * math.pi, love.math.random(6, 12)), nil, settings.sensitivity)

    self.colorIndicator.player = self.player
    
    love.mouse.setRelativeMode(true)

    self.activeChild = self.player
    self.world.tracking = self.player
    self.world.rayPreview.player = self.player
end

function game:leave(next)
    self.world.parent = nil
    love.mouse.setRelativeMode(false)
    love.mouse.setPosition(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
end

function game:resize(w, h)
    self.fpsCounter.anchor = vec(w, 0)
    self.colorIndicator.width, self.colorIndicator.height = math.min(w, h) * 0.2, math.min(w, h) * 0.2
    self.colorIndicator.anchor = vec(w, h)
end

function game:keypressed(key)
    if key == "escape" then
        switchScene("Menu")
    end
end

return floof.new(game)