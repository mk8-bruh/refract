local game = {check = true, tostring = "[game scene]"}

function game:init()
    -- UI
    self.ui = floof.new{parent = self, z = 1}
    self.ui.fpsCounter = Title(self.ui, "FPS", nil, "top right")

    -- world

    self:resize(love.graphics.getDimensions())
end

function game:resize(w, h)
    self.ui.fpsCounter:setPosition(vec(w, 0))
end

function game:draw()
    
end

return floof.new(game)