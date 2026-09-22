local game = Element{
    width = "100%", height = "100%", inLayout = false, isListener = true,
    __tostring = function(self) return "[game scene]" end
}

game.ui = Object{parent = game, z = 1}
game.fpsCounter = Label(game.ui, "FPS", {inLayout = false, alignX = "right", alignY = "top", font = love.graphics.newFont(12)})
function game.fpsCounter:update(dt)
    self.text = ("%d FPS"):format(love.timer.getFPS())
end
game.colorIndicator = ColorIndicator(game.ui, {inLayout = false, alignX = "right", alignY = "bottom"})

function game:enter(prev, seed)
    self.world = World(self, 24, seed)
    self.player = Player(self.world, vec.polar(love.math.random() * 2 * math.pi, love.math.random(6, 12)), nil, settings.sensitivity)

    self.colorIndicator.player = self.player
    
    love.mouse.setRelativeMode(true)

    self.world.tracking = self.player
    self.world.rayPreview.player = self.player
end

function game:leave(next)
    self.world:delete()
    love.mouse.setRelativeMode(false)
    love.mouse.setPosition(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
end

function game:resize(w, h)
    self.colorIndicator.w, self.colorIndicator.h = math.min(w, h) * 0.2, math.min(w, h) * 0.2
end

function game:keypressed(key)
    if key == "escape" then
        switchScene("Menu")
    end
end

return game
